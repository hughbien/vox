---
title: "Third tip!"
---

Hello, {{page.position}}!

{% if page.next %}
  [Next Post]({{page.next.path}})
{% endif %}
{% if page.next and page.next.next %}
  [Next Next Post]({{page.next.next.path}})
{% endif %}
