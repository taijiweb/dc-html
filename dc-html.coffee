###
  ported from https://github.com/cheeriojs/dom-serializer/blob/master/index.js
###

{encodeXML} = require('entities')

{domValue, List, Tag, Text, Comment, Html, Nothing, Cdata, Component, TransformComponent} = dc = require "domcom"

{booleanAttributes, unencodedElements, singleTag} = require './attrs'

Component::html = (options={}) ->
  if @valid and @encoding==options.encoding and @_html? then return @_html

  @_html = @getHtml(options)

TransformComponent::getHtml = (options) ->
  @encoding = options.encoding

  content =
    if @transformValid then @content
    else @content = @getContentComponent()

  @_html = content.html(options)

childrenHtml = (children, options) ->
  htmlList = []

  for child in children
    htmlList.push child.html(options)

  htmlList.join ""

List::getHtml = (options) ->
  @encoding = options.encoding
  childrenHtml(@children, options)

Nothing:: html = (options) -> ""

Text::getHtml = (options) ->
  @encoding = options.encoding

  text = domValue(@text)

  parentTag = @reachTag()
  if !parentTag.tagName
    parentTag.parentNode and parentTag = parentTag.parentNode

  if @encoding and parentTag.tagName in unencodedElements
    text = encodeXML(text)

  text

Cdata::getHtml = (options) ->
  @encoding = options.encoding
  "<![CDATA[#{domValue(@text)}]]>"

Html::getHtml = (options) ->
  @encoding = options.encoding

  text = domValue(@text)
  text = @transform and @transform(text) or text
  if options.encoding then text = encodeXml(text)
  text

Comment::getHtml = (options) ->
  @encoding = options.encoding
  "<!-- #{domValue(@text)} -->"

Tag::getHtml = (options) ->
  {encoding, xmlMode} = options
  @encoding = encoding

  {tagName, namespace, props} = @

  if tagName == 'svg' then xmlMode = true

  if namespace then tagHtml = namespace+':'+tagName
  else tagHtml = tagName

  html = '<' + tagHtml

  propHtml = []
  # put id="..." at the begin
  id = domValue(props.id)
  id and propHtml.push 'id="' + id

  className = @className()
  className and propHtml.push 'class="' + className + '"'

  for prop, value of props

    if prop=='id' then continue

    value = domValue(value)
    if value=='' and booleanAttributes[prop]
      propHtml.push prop
    else
      propHtml.push prop + '="' + (if encoding then encodeXML(value) else value) + '"'

  styleHtml = []
  for prop, value of @styles
    styleHtml.push prop+":"+domValue(value)
  styleHtml.length and propHtml.push "style={"+styleHtml.join('; ')+"}"

  # in dc-html, the value for events should be string, like "console.log('clicked!')"
  for prop, value of @events
    value = domValue(value)
    if value
      propHtml.push prop + '="' + (if encoding then encodeXML(value) else value) + '"'

  propHtml = propHtml.join(" ")
  propHtml and html += ' '+propHtml

  if xmlMode and !@children.length
    html += '/>'
  else
    html += '>' + childrenHtml(@children, encoding)
    if !singleTag[tagName] or xmlMode
      html += '</' + tagHtml + '>'

  html

module.exports = dc
