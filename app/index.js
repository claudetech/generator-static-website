var yeoman = require('yeoman-generator'),
    path = require('path');

module.exports = yeoman.generators.NamedBase.extend({
  constructor: function () {
    yeoman.generators.NamedBase.apply(this, arguments);
  },

  prepareDir: function () {
    this.mkdir(this.name);
    this.destinationRoot(this.name);
  },

  copyCommonFiles: function () {
    this.sourceRoot(path.join(__dirname, 'templates/common'));
    this.copy('gitignore', '.gitignore');
  },

  copyFiles: function () {
    this.sourceRoot(path.join(__dirname, 'templates/website'));
    this.directory('.', '.');
  },

  installDependencies: function () {
    if (!this.options.skipInstall) {
      this.npmInstall();
    }
  },

  initializeGit: function () {
    this.spawnCommand('git', ['init']);
  }
});
