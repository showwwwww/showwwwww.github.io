---
layout: post
title: "A state-first principle for frontend tests"
date: 2026-04-27 01:25:00 +0800
categories: frontend testing
ref: frontend-test-principle
---

The most useful frontend testing principle I keep coming back to is simple:
`UI = f(state)`. A component is a function of the state it receives and owns.
Once I accept that, a frontend unit test becomes much clearer: I do not need to
prove every pixel on the screen. I need to prove that state changes correctly,
and that React is asked to render from that state at the right moments.

![State-first frontend testing model](/assets/img/posts/frontend-test-principle/state-first-frontend-tests.png)

## The mental model

Modern frontend systems are usually described by their UI, because that is what
users see. But the UI on screen is only the last step of a pipeline.

The more stable thing to test is the data structure in memory: props, local
state, store state, cache entries, derived selectors, and event payloads. A
button click, a keyboard input, a network response, or a drag gesture is not
important because it physically happens on the page. It is important because it
changes that data structure.

So I prefer to model frontend behavior like this:

```text
current state + user action + external result -> next state
next state -> render output
```

The first arrow is business behavior. The second arrow is React's rendering
job. In most unit tests, the first arrow deserves the most attention.

## What a good unit test should prove

For component-level unit tests, I usually want confidence in three things.

First, the initial state is correct. The component should start from a known
data shape. If the initial state is wrong, every interaction after it becomes
hard to reason about.

Second, each interaction produces the right next state. When the user types,
selects, submits, expands, closes, retries, or cancels, the test should verify
the state value that matters. This can be local React state, a reducer result,
a store update, a query cache change, or a callback payload.

Third, React is asked to render when the state contract says it should render.
Sometimes that means checking that a render function was called. Sometimes it
means checking that a child component received a new prop. Sometimes it means
checking that an expensive component did not re-render when unrelated state
changed. Render count is not always a product requirement, but it can be a
useful performance contract when the component is expensive or when unnecessary
renders have caused real bugs before.

If those three things hold, I can usually trust that the component's unit-level
behavior is healthy.

## What I avoid testing too deeply

I try not to spend unit test effort proving the browser's rendering engine. If
React receives the correct state and the component returns the correct element
tree, I do not need a unit test to confirm that the browser can paint a `div`,
apply normal CSS, or dispatch a standard click event.

This does not mean DOM tests are useless. It means I want to be precise about
why I am using them. Accessibility semantics, focus behavior, form submission,
portal placement, layout-dependent behavior, and browser integration bugs can
all deserve DOM-level tests. But those tests should be chosen because the DOM is
part of the risk, not because every component test must inspect the DOM by
default.

The danger is that DOM-heavy unit tests often lock onto incidental structure.
They fail when a wrapper changes, a class name is renamed, or a harmless markup
detail moves. Those failures do not always mean the product is broken. They can
mean the test is watching the wrong thing.

## A practical test shape

When I write a frontend unit test, I like to ask one question first:

> What state transition am I trying to prove?

That question usually leads to a cleaner test shape.

```text
given: a known state
when: one user action or external event happens
then: the meaningful state changes to the expected value
and: the render contract is satisfied
```

For example, a filter panel test should not start with "does the checkbox look
checked on screen?" It can start with "when the user selects a filter, does the
selected filter state contain the correct value?" After that, I can verify that
the list receives the expected filtered data, or that the component responsible
for rendering the list is called with the right props.

This keeps the test close to the actual behavior. The checkbox is one possible
interface for changing the filter state. The state transition is the product
rule.

## The boundary

There is still a place for integration tests and E2E tests. A frontend product
is not only reducers and render functions. Real users care about routing,
network timing, CSS, accessibility, browser APIs, and visual feedback.

But I do not want every unit test to carry all of that weight. Unit tests should
make the state machine easy to trust. Integration tests should prove that
several pieces cooperate correctly. E2E tests should prove that the most
important user journeys survive in the real browser.

The layers are different because the risks are different.

## The principle

My principle is not "never test the DOM." It is:

> In unit tests, test frontend behavior as state transitions first. Treat DOM
> rendering as an output contract, and only inspect it deeply when the DOM
> itself is the risk.

This mindset makes tests smaller, more stable, and closer to the architecture
of modern frontend systems. User interactions are inputs. State changes are the
core behavior. React rendering is the projection from that state into UI.

When the state changes correctly and the render contract is called at the
expected time, I have tested the part of the frontend that my code actually
owns.
