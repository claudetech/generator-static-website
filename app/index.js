var yeoman = require('yeoman-generator'),
    path = require('path');

module.exports = yeoman.generators.NamedBase.extend({
  constructor: function () {
    yeoman.generators.NamedBase.apply(this, arguments);
    this.option('css', {
      desc: 'Select CSS templating.',
      defaults: 'stylus'
    });
    this.option('html', {
      desc: 'Select HTML templating.',
      defaults: 'jade'
    });
    this.option('save-config', {
      desc: 'Saves config in .yo-rc.json',
      defaults: true
    });
    this.option('gruntfile-path', {
      desc: 'Set the path for the Gruntfile',
      defaults: 'Gruntfile.coffee'
    });
    this.appname = this.name;
  },

  initializing: {
    prepareDir: function () {
      this.mkdir(this.name);
      this.destinationRoot(this.name);
    },
  },

  configuring: {
    initializeGit: function () {
      if (!this.options.skipGit && !this.options['skip-git']) {
        this.spawnCommand('git', ['init']);
      }
    },

    copyCommonFiles: function () {
      this.sourceRoot(path.join(__dirname, 'templates/common'));
      this.template('gitignore', '.gitignore');
      this.copy('bowerrc', '.bowerrc');
      if (!this.options.skipGruntfile) {
        this.copy('Gruntfile.coffee', this.options['gruntfile-path']);
      }
    },
  },

  writing: {
    copyFiles: function () {
      this.sourceRoot(path.join(__dirname, 'templates/website'));
      this.directory('.', '.');
    },

    copyCss: function () {
      if (this.options.css !== 'stylus' && this.options.css !== 'less') {
        this.log('Wrong CSS template engine ' + this.options.css);
        this.log('Using stylus instead.');
        this.options.css = 'stylus';
      }
      this.sourceRoot(path.join(__dirname, 'templates', 'assets', this.options.css));
      this.directory('.', 'assets/css');
    },

    copyViews: function() {
      if (this.options.html !== 'jade' && this.options.html !== 'ejs') {
        this.log('Wrong HTML template engine ' + this.options.html);
        this.log('Using jade instead.');
        this.options.html = 'jade';
      }
      this.sourceRoot(path.join(__dirname, 'templates', 'views', this.options.html));
      this.directory('.', 'views');
    },
  },

  install: {
    installDependencies: function () {
      if (!this.options.skipInstall && !this.options['skip-install']) {
        this.npmInstall();
        this.bowerInstall();
      }
    },
  },

  end: {
    saveConfig: function () {
      if (this.options['save-config']) {
        this.config.save();
      }
    }
  }
});
