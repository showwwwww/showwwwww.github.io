---
layout: post
title: "Welcome to Jekyll!"
date: 2026-04-24 01:53:00 +0800
categories: jekyll update
ref: welcome-to-jekyll
---

## What's the problem?

I ran into this problem in a previous project. The project was an Electron-based IDE with a simulator and a console, each running in an independent Electron renderer process. The simulator mocked a mini-program runtime. Inside that runtime, there were two threads: a service thread and a render thread. The service thread handled logic and computation, while the render thread transformed the data structure from the service thread into a DOM-like tree. In our implementation, these pieces were built with iframes and communicated through methods injected by Electron.

That was the background. The real problem was that this IDE needed to debug React-like mini-program components. The framework used the same core ideas as React, including Fiber, a scheduler, and a reconciler. As the business grew, these mini-program projects became more complex, so we needed a dedicated profiler for debugging the component tree. After researching the options, I found that the best approach for this situation was to use React DevTools and customize it for our project.

Jekyll requires blog post files to be named according to the following format:

`YEAR-MONTH-DAY-title.MARKUP`

Where `YEAR` is a four-digit number, `MONTH` and `DAY` are both two-digit numbers, and `MARKUP` is the file extension representing the format used in the file. After that, include the necessary front matter. Take a look at the source for this post to get an idea about how it works.

Jekyll also offers powerful support for code snippets:

{% highlight ruby %}
def print_hi(name)
puts "Hi, #{name}"
end
print_hi('Tom')
#=> prints 'Hi, Tom' to STDOUT.
{% endhighlight %}

Check out the [Jekyll docs][jekyll-docs] for more info on how to get the most out of Jekyll. File all bugs/feature requests at [Jekyll's GitHub repo][jekyll-gh]. If you have questions, you can ask them on [Jekyll Talk][jekyll-talk].

[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]: https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/
