###
  ported from https://github.com/cheeriojs/dom-serializer/blob/master/index.js
###


{expect, iit, idescribe, nit, ndescribe} = require('bdd-test-helper')

{extend} = dc = require "../index"

html = (component, options) ->
  component.html(options)

xml = (component, options) ->
  html(component, extend(options or {}, {xmlMode:true}))

describe 'render html', ->
  it 'should render <br /> tags correctly', ->
    str = '<br />'
    expect(html(str)).to.equal '<br>'

  it 'should retain encoded HTML content within attributes', ->
    str = '<hr class="cheerio &amp; node = happy parsing" />'
    expect(html(str)).to.equal '<hr class="cheerio &amp; node = happy parsing">'

  it 'should shorten the "checked" attribute when it contains the value "checked"', ->
    str = '<input checked/>'
    expect(html(str)).to.equal '<input checked>'

  it 'should not shorten the "name" attribute when it contains the value "name"', ->
    str = '<input name="name"/>'
    expect(html(str)).to.equal '<input name="name">'

  it 'should render comments correctly', ->
    str = '<!-- comment -->'
    expect(html(str)).to.equal '<!-- comment -->'

  it 'should render whitespace by default', ->
    str = '<a href="./haha.html">hi</a> <a href="./blah.html">blah</a>'
    expect(html(str)).to.equal str

  it 'should normalize whitespace if specified', ->
    str = '<a href="./haha.html">hi</a> <a href="./blah.html">blah  </a>'
    expect(html(str, normalizeWhitespace: true)).to.equal '<a href="./haha.html">hi</a> <a href="./blah.html">blah </a>'

  it 'should preserve multiple hyphens in data attributes', ->
    str = '<div data-foo-bar-baz="value"></div>'
    expect(html(str)).to.equal '<div data-foo-bar-baz="value"></div>'

  it 'should not encode characters in script tag', ->
    str = '<script>alert("hello world")</script>'
    expect(html(str)).to.equal str

  it 'should not encode json data', ->
    str = '<script>var json = {"simple_value": "value", "value_with_tokens": "&quot;here & \'there\'&quot;"};</script>'
    expect(html(str)).to.equal str

  it 'should render SVG nodes with a closing slash in HTML mode', ->
    str = '<svg><circle x="12" y="12"/><path d="123M"/><polygon points="60,20 100,40 100,80 60,100 20,80 20,40"/></svg>'
    expect(html(str)).to.equal str

  it 'should render iframe nodes with a closing slash in HTML mode', ->
    str = '<iframe src="test"></iframe>'
    expect(html(str)).to.equal str

ndescribe 'render', ->
  # only test applicable to the default setup
  describe '(html)', ->
    htmlFunc = _.partial(html, {})
    # it doesn't really make sense for {decodeEntities: false}
    # since currently it will convert <hr class='blah'> into <hr class="blah"> anyway.
    it 'should handle double quotes within single quoted attributes properly', ->
      str = '<hr class=\'an "edge" case\' />'
      expect(htmlFunc(str)).to.equal '<hr class="an &quot;edge&quot; case">'

  # run html with default options
  describe '(html, {})', _.partial(testBody, _.partial(html, {}))
  # run html with turned off decodeEntities
  describe '(html, {decodeEntities: false})', _.partial(testBody, _.partial(html, decodeEntities: false))
  describe '(xml)', ->
    it 'should render CDATA correctly', ->
      str = '<a> <b> <![CDATA[ asdf&asdf ]]> <c/> <![CDATA[ asdf&asdf ]]> </b> </a>'
      expect(xml(str)).to.equal str
