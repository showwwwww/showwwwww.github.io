---
layout: post
title: "How to embed React DevTools in your project"
date: 2025-11-19 01:53:00 +0800
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

The backend layer works like a middle layer. It runs inside the debugged page, receives data reported by the React renderer, and sends the processed information to the UI layer. One important part of this backend layer is the Overlay module. The next image shows it in more detail. It is responsible for drawing an overlay on the debugged page for the component selected in the UI layer.

### Connection of UI & Backend

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

### Overlay

For a traditional web project, the Wall replacement above is usually enough.
My case needed one more adjustment because the simulator was not a normal
browser page. It mocked a mini-program runtime with separate service and render
threads.

By default, the React DevTools backend draws the overlay in the same runtime
where the backend is installed. In this project, that was not the visual surface
the user interacted with. The selected Fiber needed to be highlighted inside the
simulator's render thread instead.

![React DevTools backend agent forwarding overlay messages](/assets/img/posts/react-devtools-custom-embed/react-agent.png)

![React DevTools overlay lookup by DOM id](/assets/img/posts/react-devtools-custom-embed/react-overlay-index.png)

The diagrams above show the extra hop. Inside the backend module, the existing
agent forwards DevTools messages between runtimes. In my project, each real DOM
node in the render thread had an id that matched the corresponding Fiber. So I
changed the parameter passed by `emit('inspectElement', ...)` from the selected
Fiber target to the selected DOM id. The agent then forwarded that id to the
React DevTools UI, so the UI could inspect and display the element selected
from the simulator.
