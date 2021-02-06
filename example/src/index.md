---
title: "Index Page"
name: "John Doe"
nested:
  nested2:
    name: "Jane Doe"
list:
  - one
  - two
  - three
object-list:
  - name: one
  - name: two
  - name: three
links: 
  - random.about
  - index
---

*Hello, {{page.name}}!*
__Hello, {{page.nested.nested2.name}}__

{{db.motto}}, what a wonderful phrase.

<ul>
  <li>List:</li>
  {% for item in page.list %}
  <li>{{ item }}</li>
  {% endfor %}
</ul>

<ul>
  <li>Object List:</li>
  {% for item in page["object-list"] %}
  <li>{{ item.name }}</li>
  {% endfor %}
</ul>

Path to random page: {{pages.random.about.path}}
Path to current page: {{page.path}}

Links:

<ul>
{% for link in page.links %}
  <li><a href="{{link.path}}">{{link.title}}</a><li>
{% endfor %}
</ul>

![Poster](assets/poster.{{prints.assets.poster_jpg}}.jpg)
<div style="height:10px;width:10px">
{{ assets.icons.heart_svg | safe }}
</div>
<div class="poster"></div>
<div class="icon-heart"></div>
