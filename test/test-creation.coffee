expect = require 'expect.js'
assert = require('yeoman-generator').assert
test   = require('yeoman-generator').test
tmp    = require 'tmp'
fs     = require 'fs-extra'
path   = require 'path'

tmpDir = process.env['TMPDIR'] ? '/tmp/generator-static-website-test'
appDir = path.join path.dirname(__dirname), 'app'

APP_NAME = 'foo'

before (done) ->
  if fs.existsSync tmpDir
    fs.removeSync tmpDir
  fs.mkdirSync tmpDir
  done()

after ->
  fs.removeSync tmpDir

describe 'generator-static-website', ->
  app = null

  beforeEach ->
    app = test.createGenerator 'static-website', [appDir], [APP_NAME], {skipInstall: true, skipGit: true}

  baseFiles = [
    'bower.json'
    '.bowerrc'
    '.gitignore'
    'Gruntfile.coffee'
    'assets/favicon.ico'
    'assets/img'
    'assets/js/app.coffee'
  ]
  jadeFiles   = ['views/index.jade', 'views/layout.jade']
  ejsFiles    = ['views/index.ejs', 'views/layout.ejs']
  stylusFiles = ['assets/css/main.styl']
  lessFiles = ['assets/css/main.less']

  runTest = (files, done) ->
    tmp.dir { unsafeCleanup: true }, (err, dir) ->
      process.chdir dir
      app.run {}, ->
        expectedFiles = (path.join(dir, APP_NAME, f) for f in files)
        assert.file(expectedFiles)
        done()

  it 'should create jade/stylus files by default', (done) ->
    files = baseFiles.concat jadeFiles, stylusFiles
    runTest files, done

  it 'should work with ejs', (done) ->
    files = baseFiles.concat ejsFiles, stylusFiles
    app.options.html = 'ejs'
    runTest files, done

  it 'should work with less', (done) ->
    files = baseFiles.concat jadeFiles, lessFiles
    app.options.css = 'less'
    runTest files, done

  it 'should work with ejs/less', (done) ->
    files = baseFiles.concat ejsFiles, lessFiles
    app.options.css = 'less'
    app.options.html = 'ejs'
    runTest files, done
