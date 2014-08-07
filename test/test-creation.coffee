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
    app = test.createGenerator 'static-website', [appDir], [APP_NAME], {skipInstall: true}

  it 'should create basic files', (done) ->
    files = [
      '.gitignore', 'Gruntfile.coffee', 'assets/css/main.styl'
      'assets/favicon.ico', 'assets/img', 'assets/js/app.coffee'
      'views/index.jade', 'views/layout.jade'
    ]
    tmp.dir { unsafeCleanup: true }, (err, dir) ->
      process.chdir dir
      app.run {}, ->
        expectedFiles = (path.join(dir, APP_NAME, f) for f in files)
        assert.file(expectedFiles)
        done()
