---
title: "Blog Index"
---

{% if blog %}
  {% for post in blog %}
* [{{ post.title }}]({{ post.path }}) on {{ post.date }}
  {% endfor %}
{% endif %}

First Post Title: {{pages.blog["hello-world"].title}}

Second Post Title: {{pages.blog["second-post"].title}}

Third Post Title: {{pages.blog["third-post"].title}}
