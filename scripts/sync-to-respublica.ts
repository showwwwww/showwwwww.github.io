/**
 * sync-to-respublica.ts
 *
 * Reads Jekyll Markdown source files, converts them to plain-text documents,
 * and bulk-ingests them into the respublica Cloudflare Worker knowledge base.
 *
 * Required env vars:
 *   BLOG_BASE_URL           e.g. https://example.github.io
 *   RESPUBLICA_INGEST_URL   e.g. https://respublica.example.workers.dev
 *   RESPUBLICA_INGEST_TOKEN  Bearer token for /admin/* endpoints
 */

import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import { basename, dirname, join } from "node:path";
import fg from "fast-glob";
import matter from "gray-matter";
import removeMd from "remove-markdown";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

type DocType = "post" | "page" | "faq" | "project";
type Visibility = "public" | "private";

interface Document {
  id: string;
  source: "github-pages";
  type: DocType;
  title: string;
  url: string;
  content: string;
  summary?: string;
  tags: string[];
  date?: string;
  updatedAt?: string;
  contentHash: string;
  visibility: Visibility;
}

interface IngestPayload {
  runId: string;
  documents: Document[];
}

interface FinalizePayload {
  runId: string;
  source: "github-pages";
  deleteMissing: boolean;
}

// ---------------------------------------------------------------------------
// Config
// ---------------------------------------------------------------------------

const BATCH_SIZE = 25;

const INCLUDE_GLOBS = [
  "_posts/**/*.{md,markdown}",
  "_pages/**/*.{md,markdown}",
  "pages/**/*.{md,markdown}",
  "content/**/*.{md,markdown}",
];

const EXCLUDE_GLOBS = ["README.md", "node_modules/**", "_site/**", ".git/**", "_drafts/**"];

// ---------------------------------------------------------------------------
// Env validation
// ---------------------------------------------------------------------------

function requireEnv(name: string): string {
  const val = process.env[name];
  if (!val) {
    console.error(`[sync] ERROR: environment variable ${name} is not set.`);
    process.exit(1);
  }
  return val;
}

function requireUrl(name: string): string {
  const val = requireEnv(name).trim().replace(/\/$/, "");
  try {
    new URL(val);
  } catch {
    console.error(
      `[sync] ERROR: ${name} is not a valid URL. ` +
        `Make sure it starts with https:// and contains no stray spaces.`
    );
    process.exit(1);
  }
  return val;
}

const BLOG_BASE_URL = requireUrl("BLOG_BASE_URL");
const RESPUBLICA_INGEST_URL = requireUrl("RESPUBLICA_INGEST_URL");
const RESPUBLICA_INGEST_TOKEN = requireEnv("RESPUBLICA_INGEST_TOKEN");

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/** Derive document type from file path. */
function inferType(filePath: string): DocType {
  const lower = filePath.toLowerCase();
  if (lower.includes("faq")) return "faq";
  if (lower.includes("project")) return "project";
  if (lower.startsWith("_posts/") || lower.includes("/_posts/")) return "post";
  return "page";
}

/** Parse YYYY-MM-DD from a _posts filename like 2026-05-01-slug.md */
function dateFromFilename(filename: string): string | undefined {
  const m = filename.match(/^(\d{4}-\d{2}-\d{2})-/);
  return m ? m[1] : undefined;
}

/** Normalise a date value from front matter to YYYY-MM-DD. */
function normaliseDate(raw: unknown): string | undefined {
  if (!raw) return undefined;
  const d = raw instanceof Date ? raw : new Date(String(raw));
  if (isNaN(d.getTime())) return undefined;
  return d.toISOString().slice(0, 10);
}

/** Normalise tags from front matter to string[]. */
function normaliseTags(fm: Record<string, unknown>): string[] {
  const raw = fm["tags"] ?? fm["tag"];
  if (!raw) return [];
  if (Array.isArray(raw)) return raw.map(String);
  if (typeof raw === "string") {
    return raw
      .split(",")
      .map((t) => t.trim())
      .filter(Boolean);
  }
  return [];
}

/**
 * Build a public URL for the document.
 *
 * Priority:
 *  1. front matter permalink (absolute → use as-is; relative → join with base)
 *  2. _posts/YYYY-MM-DD-slug.md  → BASE/YYYY/MM/DD/slug/
 *  3. pages|_pages|content/some/path.md → BASE/some/path/
 */
function buildUrl(filePath: string, fm: Record<string, unknown>): string {
  const permalink = fm["permalink"];
  if (permalink && typeof permalink === "string") {
    if (/^https?:\/\//i.test(permalink)) return permalink;
    const clean = permalink.startsWith("/") ? permalink : `/${permalink}`;
    return `${BLOG_BASE_URL}${clean}`.replace(/([^:])\/\//g, "$1/");
  }

  const filename = basename(filePath).replace(/\.(md|markdown)$/i, "");

  // _posts/YYYY-MM-DD-slug.md
  if (filePath.startsWith("_posts/") || filePath.includes("/_posts/")) {
    const m = filename.match(/^(\d{4})-(\d{2})-(\d{2})-(.+)$/);
    if (m) {
      const [, year, month, day, slug] = m;
      return `${BLOG_BASE_URL}/${year}/${month}/${day}/${slug}/`;
    }
  }

  // pages/, _pages/, content/ — strip leading directory segment(s) up to
  // the first "content layer" folder.
  const dir = dirname(filePath);
  // Remove the top-level bucket (_pages, pages, content) from the path.
  const segments = dir.split("/").filter(Boolean);
  const topBuckets = new Set(["_pages", "pages", "content", "_posts"]);
  const pathSegments = segments[0] && topBuckets.has(segments[0]) ? segments.slice(1) : segments;

  const urlPath = [...pathSegments, filename].filter(Boolean).join("/");
  return `${BLOG_BASE_URL}/${urlPath}/`;
}

/** Convert Markdown body to clean plain text. */
function toPlainText(markdown: string): string {
  const text = removeMd(markdown);
  // Collapse 3+ consecutive newlines → 2
  return text.replace(/\n{3,}/g, "\n\n").trim();
}

/** Generate contentHash from stable fields. */
function computeHash(doc: Omit<Document, "contentHash">): string {
  const payload = JSON.stringify({
    title: doc.title,
    url: doc.url,
    content: doc.content,
    tags: doc.tags,
    date: doc.date,
    updatedAt: doc.updatedAt,
  });
  return createHash("sha256").update(payload).digest("hex");
}

// ---------------------------------------------------------------------------
// Per-file processing
// ---------------------------------------------------------------------------

async function processFile(filePath: string): Promise<Document | null> {
  const raw = await readFile(filePath, "utf-8");
  const { data: fm, content: body } = matter(raw);

  const content = toPlainText(body);
  if (!content) {
    console.warn(`[sync] Skipping (empty body): ${filePath}`);
    return null;
  }

  const filename = basename(filePath);
  const id = filePath.replace(/\.(md|markdown)$/i, "").replace(/\\/g, "/");

  const type = inferType(filePath);

  const title =
    typeof fm["title"] === "string" && fm["title"]
      ? fm["title"]
      : filename.replace(/\.(md|markdown)$/i, "");

  const url = buildUrl(filePath, fm as Record<string, unknown>);

  const summary =
    typeof fm["description"] === "string"
      ? fm["description"]
      : typeof fm["excerpt"] === "string"
        ? fm["excerpt"]
        : undefined;

  const tags = normaliseTags(fm as Record<string, unknown>);

  const date = normaliseDate(fm["date"]) ?? dateFromFilename(filename);

  const updatedAt =
    normaliseDate(fm["updatedAt"]) ??
    normaliseDate(fm["updated"]) ??
    normaliseDate(fm["last_modified_at"]);

  const visibility: Visibility = fm["visibility"] === "private" ? "private" : "public";

  const partial: Omit<Document, "contentHash"> = {
    id,
    source: "github-pages",
    type,
    title,
    url,
    content,
    summary,
    tags,
    date,
    updatedAt,
    visibility,
  };

  return { ...partial, contentHash: computeHash(partial) };
}

// ---------------------------------------------------------------------------
// HTTP helpers
// ---------------------------------------------------------------------------

async function postJson(url: string, body: unknown): Promise<void> {
  const res = await fetch(url, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      authorization: `Bearer ${RESPUBLICA_INGEST_TOKEN}`,
    },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const text = await res.text().catch(() => "(no body)");
    console.error(`[sync] HTTP ${res.status} from ${url}`);
    console.error(`[sync] Response: ${text}`);
    process.exit(1);
  }
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main(): Promise<void> {
  const runId = new Date().toISOString();
  console.log(`[sync] runId: ${runId}`);
  console.log(`[sync] Base URL:  ${BLOG_BASE_URL}`);
  console.log(`[sync] Ingest URL: ${RESPUBLICA_INGEST_URL}`);

  // 1. Discover files
  const files = await fg(INCLUDE_GLOBS, {
    ignore: EXCLUDE_GLOBS,
    dot: false,
  });
  console.log(`[sync] Found ${files.length} Markdown file(s).`);

  // 2. Process files
  const documents: Document[] = [];
  for (const file of files) {
    try {
      const doc = await processFile(file);
      if (doc) documents.push(doc);
    } catch (err) {
      console.warn(`[sync] Warning: failed to process ${file}:`, err);
    }
  }

  console.log(`[sync] Generated ${documents.length} document(s).`);

  if (documents.length === 0) {
    console.warn(
      "[sync] No documents produced. Skipping ingest and finalize to avoid accidental deletion on the remote."
    );
    process.exit(0);
  }

  // 3. Batch ingest
  const batches: Document[][] = [];
  for (let i = 0; i < documents.length; i += BATCH_SIZE) {
    batches.push(documents.slice(i, i + BATCH_SIZE));
  }

  const ingestUrl = `${RESPUBLICA_INGEST_URL}/admin/ingest`;
  for (let i = 0; i < batches.length; i++) {
    const batch = batches[i];
    console.log(`[sync] Uploading batch ${i + 1}/${batches.length} (${batch.length} doc(s))…`);
    const payload: IngestPayload = { runId, documents: batch };
    await postJson(ingestUrl, payload);
  }

  console.log("[sync] All batches uploaded successfully.");

  // 4. Finalize
  const finalizeUrl = `${RESPUBLICA_INGEST_URL}/admin/finalize`;
  console.log("[sync] Calling finalize…");
  const finalizePayload: FinalizePayload = {
    runId,
    source: "github-pages",
    deleteMissing: true,
  };
  await postJson(finalizeUrl, finalizePayload);

  console.log("[sync] Finalize complete. Sync done.");
}

main();
