---
title: "First Tip!"
layout: false
---

Hello, {{page.title}}!

[Next Tip]({{page.next.path}})
{% if page.next and page.next.next %}
  [Next Next Tip]({{page.next.next.path}})
{% endif %}
