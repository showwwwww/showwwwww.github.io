---
layout: post
title: "How to Embedded React Devtools In your  project"
date: 2026-04-24 01:53:00 +0800
categories: react devtools
ref: react-devtools-custom-embed
---

## What's the problem?

I ran into this problem in a previous project. The project was an Electron-based IDE with a simulator and a console, each running in an independent Electron renderer process. The simulator mocked a mini-program runtime. Inside that runtime, there were two threads: a service thread and a render thread. The service thread handled logic and computation, while the render thread transformed the data structure from the service thread into a DOM-like tree. In our implementation, these pieces were built with iframes and communicated through methods injected by Electron.

That was the background. The real problem was that this IDE needed to debug React-like mini-program components. The framework used the same core ideas as React, including Fiber, a scheduler, and a reconciler. As the business grew, these mini-program projects became more complex, so we needed a dedicated profiler for debugging the component tree. After researching the options, I found that the best approach for this situation was to use React DevTools and customize it for our project.
