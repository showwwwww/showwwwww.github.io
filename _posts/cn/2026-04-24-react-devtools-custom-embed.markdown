---
layout: post
title: "如何在项目中嵌入 React DevTools"
date: 2026-04-24 01:53:00 +0800
categories: react devtools
ref: react-devtools-custom-embed
---

## 问题是什么？

我在之前的项目经历里遇到过这个问题。这个项目是一个基于 Electron 的 IDE，里面有模拟器和控制台，它们分别运行在两个独立的 Electron 渲染进程里。模拟器模拟的是一个小程序运行环境。在这个运行时里，有两条线程：服务线程和渲染线程。服务线程负责处理逻辑和计算，渲染线程负责把来自服务线程的数据结构渲染成一棵类 DOM 树。在我们的实现里，这些部分都是通过 iframe 搭建的，并通过 Electron 注入的方法进行通信。

这就是背景。真正的问题是：这个 IDE 需要调试类 React 的小程序组件。这个框架使用了和 React 相同的核心思路，包括 Fiber、调度器和协调器。随着业务发展，这些小程序项目变得越来越复杂，所以我们需要一个专门的性能分析器来调试组件树。经过调研后，我认为在这种场景下最合适的方式是使用 React DevTools，并针对我们的项目做定制化改造。

## 具体怎么做？

我们要做的，是把被调试页面（模拟器）和运行在控制台里的 React 组件检查器连起来，并确保 Fiber 数据能一路传递到可视化的组件树界面。

下面这张图展示的是 React DevTools 的整体架构。

![React DevTools 架构](/assets/img/posts/react-devtools-custom-embed/architecture-cn.png)

React DevTools 可以拆成五层来理解。对这个项目来说，我最关注的是其中两层：用户界面和后端。

用户界面是一个独立的 React 页面。它可以渲染在任何 React 环境里，所以不需要和被调试页面运行在同一个页面中。

后端更像是一个中间服务。它运行在被调试页面里，接收 React 渲染器上报的数据，并把处理后的信息发送给用户界面。后端里还有一个很重要的叠加层模块，下一张图会更具体地展示它。它负责在被调试页面上，为用户界面中选中的组件绘制对应的高亮覆盖层。

## 更详细的架构

下图对桥接层、后端子模块以及整体数据流做了更细的展开。

![React DevTools 详细架构：各层、桥接与后端模块及数据流](/assets/img/posts/react-devtools-custom-embed/architecture-detailed-cn.png)

继续看 Bridge 层，可以看到 Bridge 下面有一个 Wall 模块。这个模块是实现
这次集成目标的关键。

![React DevTools wall 模块源码结构](/assets/img/posts/react-devtools-custom-embed/react-wall-illustration.png)

上图是 `react-devtools-inline` backend 相关源码结构。这个 backend 会导出
`createBridge` 函数。默认情况下，`createBridge` 使用 `postMessage` 作为
wall 的实现。在我的场景里，也就是 Electron 渲染进程之间的通信，我把这层
wall 替换成了 Electron IPC，让模拟器和控制台通过宿主进程完成通信。

> 注意：自定义 wall 的入口在 React 18 之后才导出。我的项目当时仍然使用
> React 17.0.2。如果你的项目也低于 React 18，建议直接检查源码：在 React
> 17.0.2 里，wall 系统已经存在，只是没有从公开入口导出。所以我调整了
> package entry，把它暴露出来用于这次集成。
