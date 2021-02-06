---
title: "Hello World!"
name: "World"
layout: _blog.html
---

Hello, {{page.name}}!

[Next Post]({{page.next.path}})
{% if page.next and page.next.next %}
  [Next Next Post]({{page.next.next.path}})
{% endif %}
