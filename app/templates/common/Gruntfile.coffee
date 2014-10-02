livereloadPort = 35729
httpServerPort = 9000

fs         = require 'fs'
path       = require 'path'
loremIpsum = require 'lorem-ipsum'
_          = require 'lodash'

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
  cwd: 'assets'
  src: ['css/**/*.<%= cssExt %>', '!css/**/_*. <%= cssExt %>']
  dest: 'tmp'
  ext: '.css'
]
cssDistFiles = [_.extend({}, cssFiles[0], {dest: 'dist'})]

templateFiles = [
  expand: true
  cwd: 'views'
  src: ['**/*.<%= htmlExt %>', '!**/_*.<%= htmlExt %>', '!layout.<%= htmlExt %>']
  dest: 'tmp'
  ext: '.html'
]
templateDistFiles = [_.extend({}, templateFiles[0], {dest: 'dist'})]

coffeeFiles = [
  expand: true
  cwd: 'assets'
  src: ['js/**/*.coffee']
  dest: 'tmp'
  ext: '.js'
]
coffeeDistFiles = [_.extend({}, coffeeFiles[0], {dest: 'dist'})]

htmlFiles = [
  expand: true
  cwd: 'tmp'
  src: ['**/*.html']
  dest: 'tmp'
  ext: '.html'
]
htmlDistFiles = [_.extend({}, htmlFiles[0], {dest: 'dist', cwd: 'dist'})]


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
        tasks: ['copy:tmpAssets', 'brerror:<%= htmlTask %>:tmp', 'glob:tmp']
        options:
          event: ['added', 'deleted']
      coffee:
        cwd: 'assets/js'
        files: 'assets/js/**/*.coffee'
        tasks: ['brerror:newer:coffee:tmp']
        options:
          event: ['changed']
      coffeeGlob:
        cwd: 'assets/js'
        files: 'assets/js/**/*.coffee'
        tasks: ['brerror:newer:coffee:tmp', 'brerror:<%= htmlTask %>:tmp', 'glob:tmp']
        options:
          event: ['added', 'deleted']
      stylesheets:
        cwd: 'assets/css'
        files: 'assets/css/**/*.<%= cssExt %>'
        tasks: ['brerror:newer:<%= cssTask %>:tmp']
        options:
          event: ['changed']
      stylesheetsGlob:
        cwd: 'assets/css'
        files: 'assets/css/**/*.<%= cssExt %>'
        tasks: ['brerror:newer:<%= cssTask %>:tmp', 'brerror:<%= htmlTask %>:tmp', 'glob:tmp']
        options:
          event: ['added', 'deleted']
      views:
        cwd: 'views'
        files: 'views/**/*.<%= htmlExt %>'
        tasks: ['brerror:newer:<%= htmlTask %>:tmp', 'glob:tmp']
      options:
        livereload: livereloadPort

    coffee:
      tmp:
        files: coffeeFiles
      dev:
        files: coffeeDistFiles
      dist:
        files: coffeeDistFiles

<% if(options.css === 'stylus') { %>
    stylus:
      tmp:
        files: cssFiles
        options:
          compress: false
      dev:
        files: cssDistFiles
        options:
          compress: false
      dist:
        files: cssDistFiles
      options:
        use: [
          require 'axis-css'
        ]
<% } else if(options.css === 'less') { %>
    less:
      tmp:
        files: cssFiles
      dev:
        files: cssDistFiles
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
        files: templateDistFiles
        options:
          pretty: true
      dist:
        files: templateDistFiles
      options:
        data:
          lorem: lorem
<% } else if(options.html === 'ejs') { %>
    ejs:
      tmp:
        files: templateFiles
      dev:
        files: templateDistFiles
      dist:
        files: templateDistFiles
      options:
        lorem: lorem
<% } %>
    connect:
      server:
        options:
          port: httpServerPort
          keepalive: true
          debug: true
          base: 'tmp'
          useAvailablePort: true
          open: true
          livereload: true

    copy:
      tmpAssets:
        expand: true
        cwd: 'assets'
        src: ['**/*', '!css/**/*.<%= cssExt %>', '!js/**/*.coffee']
        dest: 'tmp'
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
          src: ['**/*', '!css/**/*.<%= cssExt %>', '!js/**/*.coffee']
          dest: 'dist'
        ]

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
      tmp: ['tmp']
      dist: ['dist']
      dev: ['dist']

    glob:
      tmp:
        files: htmlFiles
      dev:
        files: htmlDistFiles
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
        files: htmlDistFiles
        options:
          useLocal: true
      dist:
        files: htmlDistFiles
      options:
        incompatible: ['glob']


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
      word = filename.substr(0, filename.lastIndexOf('.'))
      return true if content.indexOf(word) > -1
    return false

  mapFile = (filepath) ->
    filepath = filepath.replace /^(assets|views)/, 'tmp'
    filepath = filepath.replace /\.<%= cssExt %>$/, '.css'
    filepath = filepath.replace /\.coffee$/, '.js'
    filepath = filepath.replace /\.<%= htmlExt %>$/, '.html'
    filepath

  grunt.event.on 'watch', (event, file, task) ->
    return unless event == 'deleted'
    filepath = path.join __dirname, mapFile(file)
    grunt.file.delete(filepath) if fs.existsSync filepath

  compileTasks = (env) -> [
    "clean:#{env}"
    "makeCopy:#{env}"
    "<%= htmlTask %>:#{env}"
    "coffee:#{env}"
    "<%= cssTask %>:#{env}"
    "cdnify:#{env}"
    "glob:#{env}"
  ]

  grunt.registerTask 'makeCopy', (env) ->
    if env == 'tmp'
      grunt.task.run ["copy:tmpAssets", "copy:tmpComponents"]
    else
      grunt.task.run ["copy:dist"]

  grunt.registerTask 'compile:tmp', compileTasks('tmp')
  grunt.registerTask 'compile:dev', compileTasks('dev')
  grunt.registerTask 'compile:dist', compileTasks('dist')

  grunt.registerTask 'default', ['compile:tmp', 'concurrent:start']
