path = require('path')
gulp = require('gulp')
gutil = require('gulp-util')

minimist = require('minimist')
argv = minimist(process.argv.slice(2))

runSequence = require('run-sequence')

changed = require('gulp-changed')
cache = require('gulp-cached')
plumber = require('gulp-plumber')

del = require('del')

mocha = require('gulp-mocha')

xtask = ->

task = gulp.task.bind(gulp)

src = gulp.src.bind(gulp)
from = (source, options={dest:'app', cache:'cache'}) ->
  options.dest ?= 'app'
  options.cache ?= 'cache'
  src(source).pipe(changed(options.dest)).pipe(cache(options.cache)).pipe(plumber())

dest = gulp.dest.bind(gulp)

FromStream = from('').constructor
FromStream::to = (dst) -> @pipe(dest(dst))
FromStream::pipelog = (obj, log=gutil.log) -> @pipe(obj).on('error', log)

task 'clean', (cb) -> del(['lib', 'test-build'], cb)

logTime = (msg) ->
  t = new Date()
  console.log("[#{t.getHours()}:#{t.getMinutes()}:#{t.getSeconds()}]: "+msg)

coffee = require('gulp-coffee')

task 'coffee', (cb) ->
  from(['./*.coffee', '!gulpfile.coffee'], {cache:'coffee'}).pipelog(coffee({bare: true})).pipe(dest('./'))
  # below is just for who prefer to reading javascript
  from(['./test/**/*.coffee'], {cache:'coffee'}).pipelog(coffee({bare: true})).pipe(dest('./test-build'))

onErrorContinue = (err) -> console.log(err.stack); @emit 'end'

task 'mocha', ->
  src('test-build/**/test*.js').pipe(mocha({reporter: 'spec'})).on("error", onErrorContinue)

task 'dev', (callback) -> runSequence 'clean', 'coffee', 'mocha', callback
task 'default', ['dev']