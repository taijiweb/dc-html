
/*
  ported from https://github.com/cheeriojs/dom-serializer/blob/master/index.js
 */
var Cdata, Comment, Component, Html, List, Nothing, Tag, Text, TransformComponent, booleanAttributes, childrenHtml, dc, domValue, encodeXML, extend, singleTag, unencodedElements, _ref, _ref1,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

encodeXML = require('entities').encodeXML;

_ref = dc = require("domcom"), extend = _ref.extend, domValue = _ref.domValue, List = _ref.List, Tag = _ref.Tag, Text = _ref.Text, Comment = _ref.Comment, Html = _ref.Html, Nothing = _ref.Nothing, Cdata = _ref.Cdata, Component = _ref.Component, TransformComponent = _ref.TransformComponent;

_ref1 = require('./attrs'), booleanAttributes = _ref1.booleanAttributes, unencodedElements = _ref1.unencodedElements, singleTag = _ref1.singleTag;

Component.prototype.html = function(options) {
  if (options == null) {
    options = {};
  }
  if (this.valid && this.encoding === options.encoding && (this._html != null)) {
    return this._html;
  }
  return this._html = this.getHtml(options);
};

TransformComponent.prototype.getHtml = function(options) {
  var content;
  this.encoding = options.encoding;
  content = this.transformValid ? this.content : this.content = this.getContentComponent();
  return this._html = content.html(options);
};

childrenHtml = function(children, options) {
  var child, htmlList, _i, _len;
  htmlList = [];
  for (_i = 0, _len = children.length; _i < _len; _i++) {
    child = children[_i];
    htmlList.push(child.html(options));
  }
  return htmlList.join("");
};

List.prototype.getHtml = function(options) {
  this.encoding = options.encoding;
  return childrenHtml(this.children, options);
};

Nothing.prototype.html = function(options) {
  return "";
};

Text.prototype.getHtml = function(options) {
  var parentTag, text, _ref2;
  this.encoding = options.encoding;
  text = domValue(this.text);
  parentTag = this.reachTag();
  if (!parentTag.tagName) {
    parentTag.parentNode && (parentTag = parentTag.parentNode);
  }
  if (this.encoding && (_ref2 = parentTag.tagName, __indexOf.call(unencodedElements, _ref2) >= 0)) {
    text = encodeXML(text);
  }
  return text;
};

Cdata.prototype.getHtml = function(options) {
  this.encoding = options.encoding;
  return "<![CDATA[" + (domValue(this.text)) + "]]>";
};

Html.prototype.getHtml = function(options) {
  var text;
  this.encoding = options.encoding;
  text = domValue(this.text);
  text = this.transform && this.transform(text) || text;
  if (options.encoding) {
    text = encodeXml(text);
  }
  return text;
};

Comment.prototype.getHtml = function(options) {
  this.encoding = options.encoding;
  return "<!-- " + (domValue(this.text)) + " -->";
};

Tag.prototype.getHtml = function(options) {
  var className, encoding, html, id, namespace, prop, propHtml, props, styleHtml, tagHtml, tagName, value, xmlMode, _ref2, _ref3;
  encoding = options.encoding, xmlMode = options.xmlMode;
  this.encoding = encoding;
  tagName = this.tagName, namespace = this.namespace, props = this.props;
  if (tagName === 'svg') {
    xmlMode = true;
  }
  if (namespace) {
    tagHtml = namespace + ':' + tagName;
  } else {
    tagHtml = tagName;
  }
  html = '<' + tagHtml;
  propHtml = [];
  id = domValue(props.id);
  id && propHtml.push('id="' + id);
  className = this.className();
  className && propHtml.push('class="' + className + '"');
  for (prop in props) {
    value = props[prop];
    if (prop === 'id') {
      continue;
    }
    prop = prop.replace(/[A-Z]/g, function(match) {
      return '-' + match.toLowerCase();
    });
    value = domValue(value);
    if (value === '' && booleanAttributes[prop]) {
      propHtml.push(prop);
    } else {
      propHtml.push(prop + '="' + (encoding ? encodeXML(value) : value) + '"');
    }
  }
  styleHtml = [];
  _ref2 = this.styles;
  for (prop in _ref2) {
    value = _ref2[prop];
    prop = prop.replace(/[A-Z]/g, function(match) {
      return '-' + match.toLowerCase();
    });
    styleHtml.push(prop + ":" + domValue(value));
  }
  styleHtml.length && propHtml.push("style={" + styleHtml.join('; ') + "}");
  _ref3 = this.events;
  for (prop in _ref3) {
    value = _ref3[prop];
    value = domValue(value);
    if (value) {
      propHtml.push(prop + '="' + (encoding ? encodeXML(value) : value) + '"');
    }
  }
  propHtml = propHtml.join(" ");
  propHtml && (html += ' ' + propHtml);
  if (xmlMode && !this.children.length) {
    html += '/>';
  } else {
    html += '>' + childrenHtml(this.children, extend({}, options, {
      xmlMode: xmlMode
    }));
    if (!singleTag[tagName] || xmlMode) {
      html += '</' + tagHtml + '>';
    }
  }
  return html;
};

module.exports = dc;
