###
000   000  000   000   0000000   00000000  000    
000  000   000   000  000        000       000    
0000000    000   000  000  0000  0000000   000    
000  000   000   000  000   000  000       000    
000   000   0000000    0000000   00000000  0000000
###

shortcut      = require 'global-shortcut'
path          = require 'path'
resolve       = require './tools/resolve'
app           = require 'app'
ipc           = require 'ipc'
fs            = require 'fs'
events        = require 'events'
Tray          = require 'tray'
BrowserWindow = require 'browser-window'

jsonStr = (a) -> JSON.stringify a, null, " "

menuBarMode = false
win   = undefined
tray  = undefined

###
000       0000000    0000000 
000      000   000  000      
000      000   000  000  0000
000      000   000  000   000
0000000   0000000    0000000 
###
    
ipc.on 'console.log',   (event, args) -> console.log.apply console, args
ipc.on 'console.error', (event, args) -> console.log.apply console, args
ipc.on 'process.exit',  (event, code) -> console.log 'exit via ipc';  process.exit code
    
noToggle = false 
ipc.on 'enableToggle', -> noToggle = false;console.log 'doToggle'
ipc.on 'disableToggle', -> noToggle = true;console.log 'noToggle'
ipc.on 'globalShortcut', (event, key) -> 
    shortcut.unregisterAll()
    shortcut.register key, toggleWindow
     
###
 0000000  000   000   0000000   000   000
000       000   000  000   000  000 0 000
0000000   000000000  000   000  000000000
     000  000   000  000   000  000   000
0000000   000   000   0000000   00     00
###

showWindow = () ->
    win.show() unless win.isVisible()
    win.setResizable true
    win

###
000000000   0000000    0000000    0000000   000      00000000
   000     000   000  000        000        000      000     
   000     000   000  000  0000  000  0000  000      0000000 
   000     000   000  000   000  000   000  000      000     
   000      0000000    0000000    0000000   0000000  00000000
###

toggleWindow = () ->
    return if noToggle
    if win && win.isVisible()
        win.hide()
    else
        win.show()

createWindow = () ->
    
    app.on 'ready', () ->

        cwd = path.join __dirname, '..'

        if menuBarMode
            if app.dock then app.dock.hide()
            iconFile = path.join cwd, 'img', 'menuicon.png'
            tray = new Tray iconFile
            tray.on 'clicked', toggleWindow
        else
            app.dock

        # 000   000  000  000   000
        # 000 0 000  000  0000  000
        # 000000000  000  000 0 000
        # 000   000  000  000  0000
        # 00     00  000  000   000

        screenSize = (require 'screen').getPrimaryDisplay().workAreaSize
        windowWidth = screenSize.width
        x = Number(((screenSize.width-windowWidth)/2).toFixed())
        y = 0
        w = windowWidth
        h = screenSize.height

        values = loadPrefs()
        if values.winpos?
            x = values.winpos[0]
            y = values.winpos[1]
        if values.winsize?
            w = values.winsize[0]
            h = values.winsize[1]

        win = new BrowserWindow
            dir:           cwd
            preloadWindow: true
            x:             x
            y:             y
            width:         w
            height:        h
            frame:         false

        try
            if values?.shortcut != ''
                shortcut.register (values?.shortcut or 'ctrl+`'), toggleWindow
        catch err
            console.log 'shortcut installation failed', err

        win.loadUrl 'file://' + cwd + '/app.html'
        
        if menuBarMode
            win.on 'blur', win.hide
            
        win.on 'resize', (e) -> 
            values = loadPrefs()
            values.winpos = win.getPosition()
            values.winsize = win.getSize()
            savePrefs values
            
        setTimeout showWindow, 100
              
createWindow()            
  
###
00000000   00000000   00000000  00000000   0000000
000   000  000   000  000       000       000     
00000000   0000000    0000000   000000    0000000 
000        000   000  000       000            000
000        000   000  00000000  000       0000000 
###

prefsFile = resolve '~/Library/Preferences/kugel.json'

loadPrefs = () ->
    try
        return JSON.parse(fs.readFileSync(prefsFile, encoding:'utf8'))
    catch err     
        return {}

savePrefs = (values) ->
    fs.writeFileSync prefsFile, jsonStr(values), encoding:'utf8'
  
