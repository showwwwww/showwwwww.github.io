---
layout: post
title: "How to embed React DevTools in your project"
date: 2026-04-24 01:53:00 +0800
categories: react devtools
ref: react-devtools-custom-embed
---

## What's the problem?

I ran into this problem in a previous project. The project was an Electron-based IDE with a simulator and a console, each running in an independent Electron renderer process. The simulator mocked a mini-program runtime. Inside that runtime, there were two threads: a service thread and a render thread. The service thread handled logic and computation, while the render thread transformed the data structure from the service thread into a DOM-like tree. In our implementation, these pieces were built with iframes and communicated through methods injected by Electron.

That was the background. The real problem was that this IDE needed to debug React-like mini-program components. The framework used the same core ideas as React, including Fiber, a scheduler, and a reconciler. As the business grew, these mini-program projects became more complex, so we needed a dedicated profiler for debugging the component tree. After researching the options, I found that the best approach for this situation was to use React DevTools and customize it for our project.

## How we did it

The concrete goal was to connect the page under debug—the simulator—to the React component inspector living in the console, and to make sure Fiber data could be bridged through to the visual tree view.

The diagram below shows the React DevTools architecture.

![React DevTools architecture](/assets/img/posts/react-devtools-custom-embed/architecture.png)

React DevTools can be understood as five layers. For this project, the two layers I cared about most were the user interface layer and the backend layer.

The user interface layer is an independent React page. It can be rendered in any React environment, so it does not need to live inside the page being debugged.

The backend layer works like a middle server. It runs inside the debugged page, receives data reported by the React renderer, and sends the processed information to the UI layer. One important part of this backend layer is the Overlay module. The next image will show it in more detail. It is responsible for drawing an overlay on the debugged page for the component selected in the UI layer.

![React DevTools detailed architecture: layers, bridge, backend, and data flow](/assets/img/posts/react-devtools-custom-embed/architecture-detailed.png)

Looking closer at the Bridge layer, there is a Wall module under Bridge. That
module is the key to this integration.

![React DevTools wall module source structure](/assets/img/posts/react-devtools-custom-embed/react-wall-illustration.png)

The image above shows the relevant source structure in the
`react-devtools-inline` backend. This backend exports a `createBridge`
function. By default, `createBridge` uses `postMessage` as its wall
implementation. In my Electron renderer-to-renderer setup, I replaced that
wall with Electron IPC, so the simulator and console could communicate through
the host process.

> Note: the customizable wall entry is exported in React 18 and later. My
> project was still on React 17.0.2. If your project is also below React 18,
> check the source code directly: in React 17.0.2, the wall system already
> exists, but it is not exported from the public entry. I changed the package
> entry to expose it for this integration.
