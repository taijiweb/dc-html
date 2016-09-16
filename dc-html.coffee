###
  ported from https://github.com/cheeriojs/dom-serializer/blob/master/index.js
###

{encodeXML} = require('entities')

{extend, domValue, List, Tag, Text, Comment, Html, Nothing, Cdata, Component, TransformComponent} = dc = require "domcom"

{booleanAttributes, unencodedElements, singleTag} = require('./attrs')

Component::html = (options={}) ->
  if @valid && @encoding==options.encoding && @_html? then return @_html

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

  text = domValue(@text, this)

  parentTag = @reachTag()
  if !parentTag.tagName
    parentTag.parentNode && parentTag = parentTag.parentNode

  if @encoding && parentTag.tagName in unencodedElements
    text = encodeXML(text)

  text

Cdata::getHtml = (options) ->
  @encoding = options.encoding
  "<![CDATA[#{domValue(@text, this)}]]>"

Html::getHtml = (options) ->
  @encoding = options.encoding

  text = domValue(@text, this)
  text = @transform && @transform(text) || text
  if options.encoding then text = encodeXml(text)
  text

Comment::getHtml = (options) ->
  @encoding = options.encoding
  "<!-- #{domValue(@text, this)} -->"

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
  id = domValue(props.id, this)
  id && propHtml.push 'id="' + id

  className = @className.call(this)
  className && propHtml.push 'class="' + className + '"'

  for prop, value of props

    if prop=='id' then continue

    prop = prop.replace(/[A-Z]/g, (match) -> '-'+match.toLowerCase())

    value = domValue(value, this)
    if value=='' && booleanAttributes[prop]
      propHtml.push prop
    else
      propHtml.push prop + '="' + (if encoding then encodeXML(value) else value) + '"'

  styleHtml = []
  for prop, value of @styles
    prop = prop.replace(/[A-Z]/g, (match) -> '-'+match.toLowerCase())
    styleHtml.push(prop+":"+domValue(value, this))
  styleHtml.length && propHtml.push "style={"+styleHtml.join('; ')+"}"

  # in dc-html, the value for events should be string, like "console.log('clicked!')"
  for prop, value of @events
    value = domValue(value, this)
    if value
      propHtml.push prop + '="' + (if encoding then encodeXML(value) else value) + '"'

  propHtml = propHtml.join(" ")
  propHtml && html += ' '+propHtml

  if xmlMode && !@children.length
    html += '/>'
  else
    html += '>' + childrenHtml(@children, extend({}, options, {xmlMode}))
    if !singleTag[tagName] || xmlMode
      html += '</' + tagHtml + '>'

  html

module.exports = dc
