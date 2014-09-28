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
  dest: 'public'
  ext: '.css'
]
cssDistFiles = [_.extend({}, cssFiles[0], {dest: 'dist'})]

htmlFiles = [
  expand: true
  cwd: 'views'
  src: ['**/*.<%= htmlExt %>', '!**/_*.<%= htmlExt %>', '!layout.<%= htmlExt %>']
  dest: 'public'
  ext: '.html'
]
htmlDistFiles = [_.extend({}, htmlFiles[0], {dest: 'dist'})]

coffeeFiles = [
  expand: true
  cwd: 'assets'
  src: ['js/**/*.coffee']
  dest: 'public'
  ext: '.js'
]
coffeeDistFiles = [_.extend({}, coffeeFiles[0], {dest: 'dist'})]


module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    watch:
      public:
        files: ['assets/**/*', '!assets/css/**/*.<%= cssExt %>','!assets/js/**/*.coffee']
        tasks: ['newer:copy:devPublic']
        options:
          event: ['changed']
      publicGlob:
        files: ['assets/**/*', '!assets/css/**/*.<%= cssExt %>', '!assets/js/**/*.coffee']
        tasks: ['copy:devPublic', 'brerror:<%= htmlTask %>:dev', 'glob:dev']
        options:
          event: ['added', 'deleted']
      coffee:
        cwd: 'assets/js'
        files: 'assets/js/**/*.coffee'
        tasks: ['brerror:newer:coffee:dev']
        options:
          event: ['changed']
      coffeeGlob:
        cwd: 'assets/js'
        files: 'assets/js/**/*.coffee'
        tasks: ['brerror:newer:coffee:dev', 'brerror:<%= htmlTask %>:dev', 'glob:dev']
        options:
          event: ['added', 'deleted']
      stylesheets:
        cwd: 'assets/css'
        files: 'assets/css/**/*.<%= cssExt %>'
        tasks: ['brerror:newer:<%= cssTask %>:dev']
        options:
          event: ['changed']
      stylesheetsGlob:
        cwd: 'assets/css'
        files: 'assets/css/**/*.<%= cssExt %>'
        tasks: ['brerror:newer:<%= cssTask %>:dev', 'brerror:<%= htmlTask %>:dev', 'glob:dev']
        options:
          event: ['added', 'deleted']
      views:
        cwd: 'views'
        files: 'views/**/*.<%= htmlExt %>'
        tasks: ['brerror:newer:<%= htmlTask %>:dev', 'glob:dev']
      options:
        livereload: livereloadPort

    coffee:
      dev:
        files: coffeeFiles
      dist:
        files: coffeeDistFiles

<% if(options.css === 'stylus') { %>
    stylus:
      dev:
        files: cssFiles
        options:
          compress: false
      dist:
        files: cssDistFiles
        options:
          compress: true
      options:
        use: [
          require 'axis-css'
        ]
<% } else if(options.css === 'less') { %>
    less:
      dev:
        files: cssFiles
      dist:
        files: cssDistFiles
<% } if(options.html === 'jade') { %>
    jade:
      dev:
        files: htmlFiles
        options:
          pretty: true
      dist:
        files: htmlDistFiles
      options:
        data:
          lorem: lorem
<% } else if(options.html === 'ejs') { %>
    ejs:
      dev:
        files: htmlFiles
      dist:
        files: cssDistFiles
      options:
        lorem: lorem
<% } %>
    connect:
      server:
        options:
          port: httpServerPort
          keepalive: true
          debug: true
          base: 'public'
          useAvailablePort: true
          open: true
          livereload: true

    copy:
      devPublic:
        expand: true
        cwd: 'assets'
        src: ['**/*', '!css/**/*.<%= cssExt %>', '!js/**/*.coffee']
        dest: 'public'
      devComponents:
          expand: true
          cwd: '.components'
          src: ['**/*', '!**/src/**']
          dest: 'public/components'
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
      dev: ['public']
      dist: ['dist']

    glob:
      dev:
        files: [
          expand: true
          cwd: 'public'
          src: ['**/*.html']
          dest: 'public'
          ext: '.html'
        ]
      dist:
        files: [
          expand: true
          cwd: 'dist'
          src: ['**/*.html']
          dest: 'dist'
          ext: '.html'
        ]
        options:
          concat: true
          minify: true


  needsCompile = (file, baseFile, time, content) ->
    stat = fs.statSync file
    if stat.isDirectory()
      dirFiles = fs.readdirSync(file)
      for f in dirFiles
        filepath = path.join file, f
        return true if needsCompile filepath, baseFile, time, content
    else
      return false if file == baseFile || stat.mtime < time
      filename = path.basename(file)
      word = filename.substr(0, filename.lastIndexOf('.'))
      return true if content.indexOf(word) > -1
    return false

  compileTasks = (env) -> [
    "clean:#{env}"
    "makeCopy:#{env}"
    "<%= htmlTask %>:#{env}"
    "coffee:#{env}"
    "<%= cssTask %>:#{env}"
    "glob:#{env}"
  ]

  grunt.registerTask 'makeCopy', (env) ->
    if env == 'dev'
      grunt.task.run ["copy:devPublic", "copy:devComponents"]
    else
      grunt.task.run ["copy:dist"]

  grunt.registerTask 'compile:dev', compileTasks('dev')
  grunt.registerTask 'compile:dist', compileTasks('dist')

  grunt.registerTask 'default', ['compile:dev', 'concurrent:start']
