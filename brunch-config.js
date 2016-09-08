exports.config = {
  sourceMaps: false,
  production: true,
  npm: {
    enabled: true
  },

  files: {
    // javascripts: {
    //   joinTo: 'thesis-editor.js'
    // },
    stylesheets: {
      joinTo: 'thesis.css'
    }
  },

  // Phoenix paths configuration
  paths: {
    // Which directories to watch
    watched: ['web/elm'],

    // Where to compile files to
    // public: 'priv/static'
  },

  modules: {
    autoRequire: {
      'thesis-editor.js': ['web/static/js/thesis-editor']
    }
  },

  // Configure your plugins
  plugins: {
    // babel: {
    //   // Do not use ES6 compiler in vendor code
    //   ignore: [/^(web\/static\/vendor)/],
    //   presets: ['es2015', 'react']
    // },
    elmBrunch: {
      mainModules: ['web/elm/Main.elm'],
      outputFolder: 'priv/js/',
      outputFile: 'thesis-editor.js'
    }
  }
}
