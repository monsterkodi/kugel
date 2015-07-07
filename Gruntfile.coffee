
module.exports = (grunt) ->

    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        pepper:
            options:
                template: '::'
                pepper:  ['log']
                paprika: ['dbg']
                join:    false
                quiet:   true
            kugel:
                files:
                    'kugel': [ 'kugel.coffee', 'coffee/**/*.coffee' ]
            release:
                options: 
                    outdir: '.'
                    type:   '.sh'
                    pepper:  null
                    paprika: null
                    join:    true
                files:
                    '.release': ['release.sh']

        salt:
            options:
                dryrun:  false
                verbose: true
                refresh: false
            coffeelarge:
                options:
                    textMarker  : '#!!'
                files:
                    'asciiText': [ 'kugel.coffee', 'coffee/**/*.coffee' ]
            coffeesmall:
                options:
                    textMarker  : '#!'
                    textPrefix  : null
                    textFill    : '# '
                    textPostfix : null
                files:
                    'asciiText': [ 'kugel.coffee', 'coffee/**/*.coffee' ]
            style: 
                options:
                    verbose     : false
                    textMarker  : '//!'
                    textPrefix  : '/*'
                    textFill    : '*  '
                    textPostfix : '*/'
                files:
                    'asciiText' : ['./style/*.styl']

        stylus:
            options:
                compress: false
            compile:
                files:
                    'style/app.css':         ['style/app.styl']
                    'style/knix-bright.css': ['style/knix-bright-style.styl']
                    'style/knix-dark.css':   ['style/knix-dark-style.styl']

        bower_concat:
            all:
                dest: 'js/lib/bower.js'
                bowerOptions:
                    relative: false
                exclude: ['octicons', 'font-awesome']

        watch:
          sources:
            files: ['./*.coffee', './coffee/**/*.coffee', '**/*.styl', '*.html']
            tasks: ['build']

        coffee:
            options:
                bare: true
            kugel:
                expand:  true,
                flatten: true,
                cwd:     '.',
                src:     ['.pepper/kugel.coffee'],
                dest:    'js',
                ext:     '.js'
            coffee:
                expand:  true,
                flatten: true,
                cwd:     '.',
                src:     ['.pepper/coffee/*.coffee'],
                dest:    'js',
                ext:     '.js'
            knix:
                expand:  true,
                flatten: true,
                cwd:     '.',
                src:     ['.pepper/coffee/knix/*.coffee'],
                dest:    'js/knix',
                ext:     '.js'
            tools:
                expand:  true,
                flatten: true,
                cwd:     '.',
                src:     ['.pepper/coffee/tools/*.coffee'],
                dest:    'js/tools',
                ext:     '.js'

        bumpup:
            file: 'package.json'
            
        clean: ['kugel.app', 'kugel.zip', 'style/*.css', 'js', 'pepper', '.release.*']
            
            
        githubAsset:
            options:
                credentials: grunt.file.readJSON('.apitoken.json') 
                repo: 'git@github.com:monsterkodi/kugel.git',
                file: 'password.zip'
                
        shell:
            options:
                execOptions: 
                    maxBuffer: Infinity
            kill:
                command: "killall Electron || echo 1"
            build: 
                command: "bash build.sh"
            test: 
                command: "electron ."
            start: 
                command: "open kugel.app"
            release:
                command: 'bash .release.sh'
            publish:
                command: 'npm publish'
                
    ###
    npm install --save-dev grunt-contrib-watch
    npm install --save-dev grunt-contrib-coffee
    npm install --save-dev grunt-contrib-stylus
    npm install --save-dev grunt-contrib-clean
    npm install --save-dev grunt-bower-concat
    npm install --save-dev grunt-bumpup
    npm install --save-dev grunt-pepper
    npm install --save-dev grunt-shell
    ###

    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-stylus'
    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-bower-concat'
    grunt.loadNpmTasks 'grunt-github-release-asset'
    grunt.loadNpmTasks 'grunt-bumpup'
    grunt.loadNpmTasks 'grunt-pepper'
    grunt.loadNpmTasks 'grunt-shell'

    grunt.registerTask 'build',     [ 'clean', 'stylus', 'salt', 'pepper', 'bower_concat', 'coffee', 'shell:kill', 'shell:build', 'shell:start' ]
    grunt.registerTask 'test',      [ 'clean', 'stylus', 'salt', 'pepper', 'bower_concat', 'coffee', 'shell:kill', 'shell:test' ]
    grunt.registerTask 'default',   [ 'test' ]