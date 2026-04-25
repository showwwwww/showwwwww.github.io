---
layout: post
title: "如何在项目中嵌入 React DevTools"
date: 2026-04-24 01:53:00 +0800
categories: react devtools
ref: react-devtools-custom-embed
---

## 问题是什么？

我在之前的项目经历里遇到过这个问题。这个项目是一个基于 Electron 的 IDE，里面有 simulator 和 console，它们分别运行在两个独立的 Electron renderer process 里。simulator 模拟的是一个小程序运行环境。在这个运行时里，有两条线程：service thread 和 render thread。service thread 负责处理逻辑和计算，render thread 负责把来自 service thread 的数据结构渲染成一棵类 DOM 树。在我们的实现里，这些部分都是通过 iframe 搭建的，并通过 Electron 注入的方法进行通信。

这就是背景。真正的问题是：这个 IDE 需要调试 React-like 的小程序组件。这个框架使用了和 React 相同的核心思路，包括 Fiber、scheduler 和 reconciler。随着业务发展，这些小程序项目变得越来越复杂，所以我们需要一个专门的 profiler 来调试组件树。经过调研后，我认为在这种场景下最合适的方式是使用 React DevTools，并针对我们的项目做定制化改造。
