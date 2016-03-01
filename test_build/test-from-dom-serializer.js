
/*
  ported from https://github.com/cheeriojs/dom-serializer/blob/master/index.js
 */
var a, br, comment, dc, ddescribe, div, expect, extend, hr, html, idescribe, iframe, iit, input, list, ndescribe, nit, script, svg, tag, xml, _ref, _ref1;

_ref = require('bdd-test-helper'), expect = _ref.expect, iit = _ref.iit, idescribe = _ref.idescribe, nit = _ref.nit, ndescribe = _ref.ndescribe, ddescribe = _ref.ddescribe;

_ref1 = dc = require("../index"), extend = _ref1.extend, tag = _ref1.tag, br = _ref1.br, hr = _ref1.hr, input = _ref1.input, a = _ref1.a, list = _ref1.list, svg = _ref1.svg, input = _ref1.input, div = _ref1.div, script = _ref1.script, iframe = _ref1.iframe, comment = _ref1.comment;

html = function(component, options) {
  return component.html(options);
};

xml = function(component, options) {
  return html(component, extend(options || {}, {
    xmlMode: true
  }));
};

describe('render html', function() {
  it('should render <br /> tags correctly', function() {
    var comp;
    comp = br();
    return expect(html(comp)).to.equal('<br>');
  });
  it('should retain encoded HTML content within attributes', function() {
    var comp;
    comp = hr({
      "class": "cheerio &amp; node = happy parsing"
    });
    return expect(html(comp)).to.equal('<hr class="cheerio &amp; node = happy parsing">');
  });
  it('should shorten the "checked" attribute when it contains the value "checked"', function() {
    var comp;
    comp = input({
      checked: ""
    });
    return expect(html(comp)).to.equal('<input type="text" checked>');
  });
  it('should not shorten the "name" attribute when it contains the value "name"', function() {
    var comp;
    comp = input({
      name: "name"
    });
    return expect(html(comp)).to.equal('<input type="text" name="name">');
  });
  it('should render comments correctly', function() {
    var comp;
    comp = comment('comment');
    return expect(html(comp)).to.equal('<!-- comment -->');
  });
  it('should render whitespace by default', function() {
    var comp;
    comp = list(a({
      href: "./haha.html"
    }, "hi"), a({
      href: "./blah.html"
    }, "blah"));
    return expect(html(comp)).to.equal("<a href=\"./haha.html\">hi</a><a href=\"./blah.html\">blah</a>");
  });
  it('should normalize whitespace if specified', function() {
    var comp;
    comp = list(a({
      href: "./haha.html"
    }, "hi"), a({
      href: "./blah.html"
    }, "blah"));
    return expect(html(comp)).to.equal('<a href="./haha.html">hi</a><a href="./blah.html">blah</a>');
  });
  it('should preserve multiple hyphens in data attributes', function() {
    var comp;
    comp = div({
      "data-foo-bar-baz": "value"
    });
    return expect(html(comp)).to.equal('<div data-foo-bar-baz="value"></div>');
  });
  it('should not encode characters in script tag', function() {
    var comp;
    comp = script('alert("hello world");');
    return expect(html(comp)).to.equal('<script>alert("hello world");</script>');
  });
  it('should not encode json data', function() {
    var comp;
    comp = script('var json = {"simple_value": "value", "value_with_tokens": "&quot;here & \'there\'&quot;"};');
    return expect(html(comp)).to.equal('<script>var json = {"simple_value": "value", "value_with_tokens": "&quot;here & \'there\'&quot;"};</script>');
  });
  it('should render SVG nodes with a closing slash in HTML mode', function() {
    var comp;
    comp = svg(tag('circle', {
      x: "12",
      y: "12"
    }), '<path d="123M"/><polygon points="60,20 100,40 100,80 60,100 20,80 20,40"/>');
    return expect(html(comp)).to.equal('<svg><circle x="12" y="12"/><path d="123M"/><polygon points="60,20 100,40 100,80 60,100 20,80 20,40"/></svg>');
  });
  return it('should render iframe nodes with a closing slash in HTML mode', function() {
    var comp;
    comp = iframe({
      src: "test"
    });
    return expect(html(comp)).to.equal('<iframe src="test"></iframe>');
  });
});

ndescribe('render', function() {
  describe('(html)', function() {
    var htmlFunc;
    htmlFunc = _.partial(html, {});
    return it('should handle double quotes within single quoted attributes properly', function() {
      var comp;
      comp = '<hr class=\'an "edge" case\' />';
      return expect(htmlFunc(comp)).to.equal('<hr class="an &quot;edge&quot; case">');
    });
  });
  describe('(html, {})', _.partial(testBody, _.partial(html, {})));
  describe('(html, {decodeEntities: false})', _.partial(testBody, _.partial(html, {
    decodeEntities: false
  })));
  return describe('(xml)', function() {
    return it('should render CDATA correctly', function() {
      var comp;
      comp = '<a> <b> <![CDATA[ asdf&asdf ]]> <c/> <![CDATA[ asdf&asdf ]]> </b> </a>';
      return expect(xml(comp)).to.equal(comp);
    });
  });
});
