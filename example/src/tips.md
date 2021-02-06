---
title: "Tips Index"
---

{% for tip in tips %}
* [{{tip.title}}]({{tip.path}}) at {{tip.position}}
{% endfor %}

First Post Title: {{pages.tips["01-first-tip"].title}}

Second Post Title: {{pages.tips["02-second-tip"].title}}

Third Post Title: {{pages.tips["03-third-tip"].title}}
