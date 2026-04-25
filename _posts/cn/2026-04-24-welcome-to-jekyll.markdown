---
layout: post
title: "你好，Jekyll！"
date: 2026-04-24 01:53:00 +0800
categories: jekyll update
ref: welcome-to-jekyll
---

这篇文章在 `_posts/cn/` 目录下。修改它然后重新构建网站，就能看到变化。重新构建的方式有很多种，最常见的是运行 `jekyll serve` 启动一个本地服务器，它会在文件改动时自动重新生成站点。

Jekyll 要求博文文件按下面的格式命名：

`YEAR-MONTH-DAY-title.MARKUP`

其中 `YEAR` 是四位数年份，`MONTH` 和 `DAY` 是两位数的月和日，`MARKUP` 是文件扩展名（用来表示文件格式）。命名之后，再写好必要的 front matter。可以参考这篇文章的源码，了解它是怎么组织的。

Jekyll 也提供了对代码片段的良好支持：

{% highlight ruby %}
def print_hi(name)
puts "Hi, #{name}"
end
print_hi('Tom')
#=> 在标准输出打印 'Hi, Tom'。
{% endhighlight %}

更多内容可以查看 [Jekyll 文档][jekyll-docs]。问题反馈和功能建议请提交到 [Jekyll 的 GitHub 仓库][jekyll-gh]。也可以去 [Jekyll Talk][jekyll-talk] 提问。

[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]: https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/
