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
  {{#page.list}}
  <li>{{.}}</li>
  {{/page.list}}
</ul>

<ul>
  <li>Object List:</li>
  {{#page.object-list}}
  <li>{{name}}</li>
  {{/page.object-list}}
</ul>

Path to random page: {{pages.random.about.path}}
Path to current page: {{page.path}}

Links:

<ul>
{{#page.links}}
  <li><a href="{{path}}">{{title}}</a><li>
{{/page.links}}
</ul>

![Poster](assets/poster.{{prints.assets.poster_jpg}}.jpg)
