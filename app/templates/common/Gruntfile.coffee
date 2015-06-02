fs         = require 'fs'
path       = require 'path'
loremIpsum = require 'lorem-ipsum'
dummyImage = require 'dummy-image'
_          = require 'lodash'

extraConfigFile = '<%= options['is-leaves'] ? '.leavesrc' : '.extra-config'  %>'

defaults =
  i18n:
    localesDir: 'locales'
  html:
    ext: '.html'
  css:
    outdir: 'css'
  js:
    outdir: 'js'
  ports:
    http: 9000
    livereload: 35729
  dir:
    tmp: 'tmp'
    dist: 'dist'
  app:
    singlePage: false

extraConfig = defaults
if fs.existsSync extraConfigFile
  _.merge extraConfig, JSON.parse fs.readFileSync(extraConfigFile, 'utf8')
extraConfig.dev = _.merge {}, _.omit(extraConfig, 'dev', 'dist'), extraConfig.dev
extraConfig.dist = _.merge {}, _.omit(extraConfig, 'dev', 'dist'), extraConfig.dist

capitalize = (s) -> s[0].toUpperCase() + s.substring(1)

generatedImages = []

dumimg = (dist, dir) ->
  (options) ->
    if _.isNumber(options) || _.isString(options)
      [width, height, type, replace] = arguments
      height = width unless height
      options = {width: width, height: height, type: type, replace: replace}

    return options.replace if options.replace? && dist

    generated = _.find(generatedImages, options)
    return generated.path if generated
    generatedOptions = _.clone(options)
    generatedImages.push(generatedOptions)

    baseDir = path.join(__dirname, dir)
    options.outputDir = path.join(baseDir, 'img', 'dummy')
    fs.mkdirSync options.outputDir unless fs.existsSync options.outputDir
    imgPath = dummyImage(options)
    generatedOptions.path = path.relative(baseDir, imgPath)

lorem = (count, options={}) ->
  if typeof count == 'number'
    options.count = count
  else
    options = count ? {}
  options.units ?= 'words'
  loremIpsum options
<% if (options.css === 'stylus') { var cssTask = 'stylus', cssExt = 'styl'; } else { var cssTask = 'less', cssExt = 'less'; } %>
<% if (options.html === 'jade') { var htmlTask = 'jade', htmlExt = 'jade'; } else { var htmlTask = 'ejs', htmlExt = 'ejs'; } %>
cssFiles = [
  expand: true
  cwd: 'assets/css'
  src: ['**/*.<%= cssExt %>', '!**/_*.<%= cssExt %>']
  dest: path.join extraConfig.dir.tmp, extraConfig.dev.css.outdir
  ext: '.css'
]
cssDevFiles  = [_.extend {}, cssFiles[0], {dest: path.join(extraConfig.dir.dist, extraConfig.dev.css.outdir)}]
cssDistFiles = [_.extend {}, cssFiles[0], {dest: path.join(extraConfig.dir.dist, extraConfig.dist.css.outdir)}]

templateFiles = [
  expand: true
  cwd: 'views'
  src: ['**/*.<%= htmlExt %>', '!**/_*.<%= htmlExt %>', '!layout.<%= htmlExt %>']
  dest: extraConfig.dir.tmp
  ext: extraConfig.dev.html.ext
]
templateDistFiles = [_.extend({}, templateFiles[0], {dest: extraConfig.dir.dist, ext: extraConfig.dist.html.ext})]
templateDevFiles = [_.extend({}, templateFiles[0], {dest: extraConfig.dir.dist})]

coffeeFiles = [
  expand: true
  cwd: 'assets/js'
  src: ['**/*.coffee']
  dest: path.join extraConfig.dir.tmp, extraConfig.dev.js.outdir
  ext: '.js'
]
coffeeDistFiles = [_.extend({}, coffeeFiles[0], {dest: path.join(extraConfig.dir.dist, extraConfig.dist.js.outdir)})]
coffeeDevFiles = [_.extend({}, coffeeFiles[0], {dest: path.join(extraConfig.dir.dist, extraConfig.dev.js.outdir)})]

htmlFiles = [
  expand: true
  cwd: extraConfig.dir.tmp
  src: ["**/*#{extraConfig.html.ext}", "!**/_*#{extraConfig.html.ext}", "!components/**"]
  dest: extraConfig.dir.tmp
  ext: extraConfig.dev.html.ext
]
htmlDistFiles = [_.extend({}, htmlFiles[0], {dest: extraConfig.dir.dist, cwd: extraConfig.dir.dist, ext: extraConfig.dist.html.ext})]
htmlDevFiles = [_.extend({}, htmlFiles[0], {dest: extraConfig.dir.dist, cwd: extraConfig.dir.dist})]

i18n = false

i18nOptions =
  tmp:
    options:
      baseDir: extraConfig.dir.tmp
      outputDir: extraConfig.dir.tmp
  dev: {}
  dist: {}
  options:
    fileFormat: 'yml'
    baseDir: extraConfig.dir.dist
    outputDir: extraConfig.dir.dist
    exclude: ['components/']
    locales: []
    locale: 'en'
    localesPath: extraConfig.i18n.localesDir

if fs.existsSync i18nOptions.options.localesPath
  files = fs.readdirSync i18nOptions.options.localesPath
  unless _.isEmpty(files)
    i18n = true
    i18nOptions.options.locales = _.map files, (f) -> f.substring(0, f.lastIndexOf('.'))

if extraConfig?.i18n?
  _.merge i18nOptions.options, extraConfig.i18n

Array::push.apply i18nOptions.options.exclude, _.map(i18nOptions.options.locales, (l) -> l + '/')

module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    watch:
      assets:
        files: ['assets/**/*', '!assets/css/**/*.<%= cssExt %>','!assets/js/**/*.coffee']
        tasks: ['newer:copy:tmpAssets']
        options:
          event: ['changed']
      assetsGlob:
        files: ['assets/**/*', '!assets/css/**/*.<%= cssExt %>', '!assets/js/**/*.coffee']
        tasks: ['copy:tmpAssets', 'runViews:tmp:true']
        options:
          event: ['added', 'deleted']
      coffee:
        cwd: 'assets/js'
        files: 'assets/js/**/*.coffee'
        tasks: ['runCoffee:tmp:true:true']
        options:
          event: ['changed']
      coffeeGlob:
        cwd: 'assets/js'
        files: 'assets/js/**/*.coffee'
        tasks: ['runCoffee:tmp:true:true', 'runViews:tmp:true']
        options:
          event: ['added', 'deleted']
      stylesheets:
        cwd: 'assets/css'
        files: 'assets/css/**/*.<%= cssExt %>'
        tasks: ['run<%= _.capitalize(cssTask) %>:tmp:true:true']
        options:
          event: ['changed']
      stylesheetsGlob:
        cwd: 'assets/css'
        files: 'assets/css/**/*.<%= cssExt %>'
        tasks: ['run<%= _.capitalize(cssTask) %>:tmp:true:true', 'runViews:tmp:true']
        options:
          event: ['added', 'deleted']
      views:
        cwd: 'views'
        files: ['views/**/*.<%= htmlExt %>', 'views/**/*.{html,md}']
        tasks: ['runViews:tmp:true']
      locales:
        files: "#{i18nOptions.options.localesPath}/**/*.#{i18nOptions.options.fileFormat}"
        tasks: ['runViews:tmp:true']
      dummy_images:
        files: ['tmp/img/dummy/*']
      options:
        spawn: false
        livereload:
            port: extraConfig.ports.livereload

    coffee:
      tmp:
        files: coffeeFiles
      dev:
        files: coffeeDevFiles
      dist:
        files: coffeeDistFiles

<% if(options.css === 'stylus') { %>
    stylus:
      tmp:
        files: cssFiles
        options:
          compress: false
      dev:
        files: cssDevFiles
        options:
          compress: false
      dist:
        files: cssDistFiles
<% } else if(options.css === 'less') { %>
    less:
      tmp:
        files: cssFiles
      dev:
        files: cssDevFiles
      dist:
        files: cssDistFiles
        options:
          compress: true
<% } if(options.html === 'jade') { %>
    jade:
      tmp:
        files: templateFiles
        options:
          pretty: true
      dev:
        files: templateDevFiles
        options:
          pretty: true
          data:
            lorem: lorem
            dev: true
            dumimg: dumimg(false, extraConfig.dir.dist)
      dist:
        files: templateDistFiles
        options:
          data:
            lorem: lorem
            dev: false
            dumimg: dumimg(true, extraConfig.dir.dist)
      options:
        data:
          lorem: lorem
          dev: true
          dumimg: dumimg(false, extraConfig.dir.tmp)
<% } else if(options.html === 'ejs') { %>
    ejs:
      tmp:
        files: templateFiles
      dev:
        files: templateDevFiles
        options:
          lorem: lorem
          dev: true
          dumimg: dumimg(false, extraConfig.dir.dist)
      dist:
        files: templateDistFiles
        options:
          lorem: lorem
          dev: false
          dumimg: dumimg(true, extraConfig.dir.dist)
      options:
        lorem: lorem
        dev: true
        dumimg: dumimg(false, extraConfig.dir.tmp)
<% } %>
    connect:
      server:
        options:
          port: extraConfig.ports.http
          keepalive: true
          debug: true
          base: extraConfig.dir.tmp
          useAvailablePort: true
          open: true
          livereload: extraConfig.ports.livereload
          middleware: (connect, options, middlewares) ->
            middlewares.push (req, res, next) ->
              return next() unless req.headers['accept'].indexOf('text/html') >= 0
              return next() unless extraConfig.app.singlePage

              file = extraConfig.app.singlePage
              file = 'index.html' unless path.extname(file) == '.html'
              filepath = path.join(extraConfig.dir.tmp, file)
              stat = fs.statSync filepath
              res.writeHead 200,
                'Content-Type': 'text/html'
                'Content-Length': stat.size
              res.write fs.readFileSync(filepath)
              res.end()
              next()

            middlewares

    copy:
      tmpAssets:
        expand: true
        cwd: 'assets'
        src: ['**/*', '!css', '!js', '!css/**/*.<%= cssExt %>', '!js/**/*.coffee']
        dest: extraConfig.dir.tmp
      tmpComponents:
          expand: true
          cwd: '.components'
          src: ['**/*', '!**/src/**']
          dest: 'tmp/components'
      dist:
        files: [
          expand: true
          cwd: '.components'
          src: ['**/*', '!**/src/**']
          dest: 'dist/components'
        ,
          expand: true
          cwd: 'assets'
          src: ['**/*', '!css', '!js', '!css/**/*.<%= cssExt %>', '!js/**/*.coffee', '!img/**/*.{png,jpg,gif}']
          dest: extraConfig.dir.dist
        ]

    imagemin:
      dist:
        files: [
          expand: true
          cwd: 'assets'
          src: ['img/**/*.{png,jpg,gif}']
          dest: extraConfig.dir.dist
        ]
      tmp: {}
      dev: {}

    concurrent:
      start:
        tasks: ['connect', 'watch', 'brerror:server']
        options:
          logConcurrentOutput: true
          gruntPath: path.join __dirname, 'node_modules', 'grunt-cli', 'bin', 'grunt'

    newer:
      options:
        override: (detail, include) ->
          cwdPath = grunt.config("#{detail.task}.#{detail.target}.files.0.cwd")
          return include() unless cwdPath?
          cwd = path.join __dirname, cwdPath
          baseFile = path.join __dirname, detail.path
          content = fs.readFileSync baseFile, 'utf8'
          compile = needsCompile cwd, baseFile, detail.time, content
          include(compile)

    clean:
      tmp: [extraConfig.dir.tmp]
      dist: [extraConfig.dir.dist]
      dev: [extraConfig.dir.dist]

    glob:
      tmp:
        files: htmlFiles
      dev:
        files: htmlDevFiles
      dist:
        files: htmlDistFiles
        options:
          concat: true
          minify: true

    cdnify:
      tmp:
        files: htmlFiles
        options:
          useLocal: true
      dev:
        files: htmlDevFiles
        options:
          useLocal: true
      dist:
        files: htmlDistFiles
      options:
        incompatible: ['glob']

    i18n: i18nOptions


  needsCompile = (file, baseFile, time, content) ->
    stat = fs.statSync file
    if stat.isDirectory()
      dirFiles = fs.readdirSync(file)
      for f in dirFiles
        filepath = path.join file, f
        return true if needsCompile filepath, baseFile, time, content
    else
      return false if file == baseFile || stat.mtime > time
      filename = path.basename(file)
      return false if filename[0] == '.'
      word = filename.substr(0, filename.lastIndexOf('.'))
      return true if content.indexOf(word) > -1
    return false

  mapFile = (filepath) ->
    filepath = filepath.replace /^(assets|views)/, extraConfig.dir.tmp
    filepath = filepath.replace /\.<%= cssExt %>$/, '.css'
    filepath = filepath.replace /\.coffee$/, '.js'
    filepath = filepath.replace /\.<%= htmlExt %>$/, '.html'
    filepath

  grunt.event.on 'watch', (event, file, task) ->
    return unless event == 'deleted'
    filepath = path.join __dirname, mapFile(file)
    grunt.file.delete(filepath) if fs.existsSync filepath


  grunt.registerTask 'makeCopy', (env) ->
    if env == 'tmp'
      grunt.task.run ["copy:tmpAssets", "copy:tmpComponents"]
    else
      grunt.task.run ["copy:dist"]


  grunt.registerTask 'views', (env, brerror, useNewer) ->
    prefixes = []
    prefixes.push 'brerror' if brerror
    prefixes.push 'newer' if useNewer
    prefix = prefixes.join(':')
    prefix += ':' unless _.isEmpty(prefix)
    tasks = [
      "#{prefix}<%= htmlTask %>:#{env}"
      "cdnify:#{env}"
      "glob:#{env}"
    ]
    tasks.push "i18n:#{env}" if i18n
    grunt.task.run tasks

  compileTasks = [
    'clean'
    'makeCopy'
    'imagemin'
    '<%= cssTask %>'
    'coffee'
    'views'
  ]

  suffixedTasks = ['views']

  _.each compileTasks, (task) ->
    capTask = capitalize(task)
    grunt.registerTask "run#{capTask}", (env, newer, brerror) ->
      [prefix, suffix] = ['', '']
      if task in suffixedTasks
        suffix += ':true' if newer
        suffix += ':true' if brerror
      else
        prefix += 'brerror:' if brerror
        prefix += 'newer:' if newer
      tasks = []
      tasks.push "before#{capTask}:#{env}" if grunt.task.exists("before#{capTask}")
      tasks.push "#{prefix}#{task}:#{env}#{suffix}"
      tasks.push "after#{capTask}:#{env}" if grunt.task.exists("after#{capTask}")
      grunt.event.emit "#{task}.run", env
      grunt.task.run tasks


  grunt.registerTask 'compile', 'Compiles the website', (env) ->
    tasks = _.map compileTasks, (t) -> "run#{capitalize(t)}:#{env}"
    tasks.unshift "beforeCompile:#{env}" if grunt.task.exists("beforeCompile")
    tasks.push "afterCompile:#{env}" if grunt.task.exists("afterCompile")
    grunt.task.run tasks

  grunt.registerTask 'default', ['compile:tmp', 'concurrent:start']

  if fs.existsSync('grunt.hooks.coffee') || fs.existsSync('grunt.hooks.js')
    require('./grunt.hooks')(grunt, extraConfig)

  grunt.event.emit 'loaded'
