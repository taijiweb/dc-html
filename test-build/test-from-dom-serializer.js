
/*
  ported from https://github.com/cheeriojs/dom-serializer/blob/master/index.js
 */
var dc, expect, extend, html, idescribe, iit, ndescribe, nit, xml, _ref;

_ref = require('bdd-test-helper'), expect = _ref.expect, iit = _ref.iit, idescribe = _ref.idescribe, nit = _ref.nit, ndescribe = _ref.ndescribe;

extend = (dc = require("../index")).extend;

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
    var str;
    str = '<br />';
    return expect(html(str)).to.equal('<br>');
  });
  it('should retain encoded HTML content within attributes', function() {
    var str;
    str = '<hr class="cheerio &amp; node = happy parsing" />';
    return expect(html(str)).to.equal('<hr class="cheerio &amp; node = happy parsing">');
  });
  it('should shorten the "checked" attribute when it contains the value "checked"', function() {
    var str;
    str = '<input checked/>';
    return expect(html(str)).to.equal('<input checked>');
  });
  it('should not shorten the "name" attribute when it contains the value "name"', function() {
    var str;
    str = '<input name="name"/>';
    return expect(html(str)).to.equal('<input name="name">');
  });
  it('should render comments correctly', function() {
    var str;
    str = '<!-- comment -->';
    return expect(html(str)).to.equal('<!-- comment -->');
  });
  it('should render whitespace by default', function() {
    var str;
    str = '<a href="./haha.html">hi</a> <a href="./blah.html">blah</a>';
    return expect(html(str)).to.equal(str);
  });
  it('should normalize whitespace if specified', function() {
    var str;
    str = '<a href="./haha.html">hi</a> <a href="./blah.html">blah  </a>';
    return expect(html(str, {
      normalizeWhitespace: true
    })).to.equal('<a href="./haha.html">hi</a> <a href="./blah.html">blah </a>');
  });
  it('should preserve multiple hyphens in data attributes', function() {
    var str;
    str = '<div data-foo-bar-baz="value"></div>';
    return expect(html(str)).to.equal('<div data-foo-bar-baz="value"></div>');
  });
  it('should not encode characters in script tag', function() {
    var str;
    str = '<script>alert("hello world")</script>';
    return expect(html(str)).to.equal(str);
  });
  it('should not encode json data', function() {
    var str;
    str = '<script>var json = {"simple_value": "value", "value_with_tokens": "&quot;here & \'there\'&quot;"};</script>';
    return expect(html(str)).to.equal(str);
  });
  it('should render SVG nodes with a closing slash in HTML mode', function() {
    var str;
    str = '<svg><circle x="12" y="12"/><path d="123M"/><polygon points="60,20 100,40 100,80 60,100 20,80 20,40"/></svg>';
    return expect(html(str)).to.equal(str);
  });
  return it('should render iframe nodes with a closing slash in HTML mode', function() {
    var str;
    str = '<iframe src="test"></iframe>';
    return expect(html(str)).to.equal(str);
  });
});

ndescribe('render', function() {
  describe('(html)', function() {
    var htmlFunc;
    htmlFunc = _.partial(html, {});
    return it('should handle double quotes within single quoted attributes properly', function() {
      var str;
      str = '<hr class=\'an "edge" case\' />';
      return expect(htmlFunc(str)).to.equal('<hr class="an &quot;edge&quot; case">');
    });
  });
  describe('(html, {})', _.partial(testBody, _.partial(html, {})));
  describe('(html, {decodeEntities: false})', _.partial(testBody, _.partial(html, {
    decodeEntities: false
  })));
  return describe('(xml)', function() {
    return it('should render CDATA correctly', function() {
      var str;
      str = '<a> <b> <![CDATA[ asdf&asdf ]]> <c/> <![CDATA[ asdf&asdf ]]> </b> </a>';
      return expect(xml(str)).to.equal(str);
    });
  });
});
