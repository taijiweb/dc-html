###
  ported from https://github.com/cheeriojs/dom-serializer/blob/master/index.js
###


{expect, iit, idescribe, nit, ndescribe} = require('bdd-test-helper')

{extend, tag, br, hr, input, a, list, svg, input, div, script, iframe, comment} = dc = require "../index"

html = (component, options) ->
  component.html(options)

xml = (component, options) ->
  html(component, extend(options or {}, {xmlMode:true}))


describe 'render html', ->
  it 'should render <br /> tags correctly', ->
    comp = br()
    expect(html(comp)).to.equal '<br>'

  it 'should retain encoded HTML content within attributes', ->
    comp = hr(class:"cheerio &amp; node = happy parsing")
    expect(html(comp)).to.equal '<hr class="cheerio &amp; node = happy parsing">'

  it 'should shorten the "checked" attribute when it contains the value "checked"', ->
    comp = input(checked:"")
    expect(html(comp)).to.equal '<input type="text" checked>'

  it 'should not shorten the "name" attribute when it contains the value "name"', ->
    comp = input(name:"name")
    expect(html(comp)).to.equal '<input type="text" name="name">'

  it 'should render comments correctly', ->
    comp = comment('comment')
    expect(html(comp)).to.equal '<!-- comment -->'

  it 'should render whitespace by default', ->
    comp = list(a({href:"./haha.html"}, "hi"), a({href:"./blah.html"}, "blah"))
    expect(html(comp)).to.equal "<a href=\"./haha.html\">hi</a><a href=\"./blah.html\">blah</a>"

  it 'should normalize whitespace if specified', ->
    comp = list a({href:"./haha.html"}, "hi"), a(href:"./blah.html", "blah")
    expect(html(comp)).to.equal '<a href="./haha.html">hi</a><a href="./blah.html">blah</a>'

  iit 'should preserve multiple hyphens in data attributes', ->
    comp = div("data-foo-bar-baz":"value")
    expect(html(comp)).to.equal '<div data-foo-bar-baz="value"></div>'

  it 'should not encode characters in script tag', ->
    comp = script('alert("hello world")')
    expect(html(comp)).to.equal comp

  it 'should not encode json data', ->
    comp = script('var json = {"simple_value": "value", "value_with_tokens": "&quot;here & \'there\'&quot;"};')
    expect(html(comp)).to.equal comp

  it 'should render SVG nodes with a closing slash in HTML mode', ->
    comp = svg(tag('circle', {x:"12", y:"12"}), '<path d="123M"/><polygon points="60,20 100,40 100,80 60,100 20,80 20,40"/>')
    expect(html(comp)).to.equal comp

  it 'should render iframe nodes with a closing slash in HTML mode', ->
    comp = iframe(src:"test")
    expect(html(comp)).to.equal comp

ndescribe 'render', ->
  # only test applicable to the default setup
  describe '(html)', ->
    htmlFunc = _.partial(html, {})
    # it doesn't really make sense for {decodeEntities: false}
    # since currently it will convert <hr class='blah'> into <hr class="blah"> anyway.
    it 'should handle double quotes within single quoted attributes properly', ->
      comp = '<hr class=\'an "edge" case\' />'
      expect(htmlFunc(comp)).to.equal '<hr class="an &quot;edge&quot; case">'

  # run html with default options
  describe '(html, {})', _.partial(testBody, _.partial(html, {}))
  # run html with turned off decodeEntities
  describe '(html, {decodeEntities: false})', _.partial(testBody, _.partial(html, decodeEntities: false))
  describe '(xml)', ->
    it 'should render CDATA correctly', ->
      comp = '<a> <b> <![CDATA[ asdf&asdf ]]> <c/> <![CDATA[ asdf&asdf ]]> </b> </a>'
      expect(xml(comp)).to.equal comp
