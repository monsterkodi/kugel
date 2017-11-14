###
 0000000   00000000   00000000   
000   000  000   000  000   000  
000000000  00000000   00000000   
000   000  000        000        
000   000  000        000
###

{ about, prefs, post, noon, fs, log } = require 'kxk'

pkg      = require '../package.json'
electron = require 'electron'

Menu     = require './menu' 
Window   = electron.BrowserWindow
app      = null

# 000   000  000  000   000   0000000
# 000 0 000  000  0000  000  000     
# 000000000  000  000 0 000  0000000 
# 000   000  000  000  0000       000
# 00     00  000  000   000  0000000 

win         = null
wins        = -> Window.getAllWindows()
visibleWins = -> (w for w in wins() when w?.isVisible() and not w?.isMinimized())
winWithID   = (winID) -> Window.fromId winID

# 000  00000000    0000000
# 000  000   000  000     
# 000  00000000   000     
# 000  000        000     
# 000  000         0000000

post.on 'toggleDevTools', => win.browserWindow.toggleDevTools()
post.on 'maximizeWindow', => app.maximizeWindow()
                        
# 000   000  000   000   0000000   00000000  000       0000000   00000000   00000000     
# 000  000   000   000  000        000       000      000   000  000   000  000   000    
# 0000000    000   000  000  0000  0000000   000      000000000  00000000   00000000     
# 000  000   000   000  000   000  000       000      000   000  000        000          
# 000   000   0000000    0000000   00000000  0000000  000   000  000        000          

class App
    
    constructor: () -> 
        
        prefs.init()
        Menu.init @
        
        @createWindow()

    # 000   000  000  000   000  0000000     0000000   000   000   0000000
    # 000 0 000  000  0000  000  000   000  000   000  000 0 000  000     
    # 000000000  000  000 0 000  000   000  000   000  000000000  0000000 
    # 000   000  000  000  0000  000   000  000   000  000   000       000
    # 00     00  000  000   000  0000000     0000000   00     00  0000000 

    reloadWin: (win) -> win?.webContents.reloadIgnoringCache()

    maximizeWindow: ->
        
        if win?
            if win.isMaximized()
                win.unmaximize() 
            else
                win.maximize()        
        else
            @showWindows()             

    hideWindows: =>
        
        for w in wins()
            w.hide()
            
    showWindows: =>
        
        for w in wins()
            w.show()
            
    raiseWindows: =>
        
        if visibleWins().length
            for w in visibleWins()
                w.showInactive()
            visibleWins()[0].showInactive()
            visibleWins()[0].focus()
        
    screenSize: -> electron.screen.getPrimaryDisplay().workAreaSize
                    
    #  0000000  00000000   00000000   0000000   000000000  00000000
    # 000       000   000  000       000   000     000     000     
    # 000       0000000    0000000   000000000     000     0000000 
    # 000       000   000  000       000   000     000     000     
    #  0000000  000   000  00000000  000   000     000     00000000
       
    createWindow: ->
        
        bounds = prefs.get 'bounds', null
        if not bounds
            {w, h} = @screenSize()
            bounds = {}
            bounds.width = w
            bounds.height = h
            bounds.x = 0
            bounds.y = 0
            
        win = new Window
            x:               bounds.x
            y:               bounds.y
            width:           bounds.width
            height:          bounds.height
            minWidth:        556
            minHeight:       206
            useContentSize:  true
            fullscreenable:  false
            fullscreen:      false
            show:            false
            backgroundColor: '#111'
            titleBarStyle:   'hidden'

        win.loadURL "file://#{__dirname}/index.html"
        
        win.on 'move',   @saveBounds
        win.on 'resize', @saveBounds     
        
        winReadyToShow = =>
            win.show()
            win.focus()
             
            if true then win.webContents.openDevTools()
                        
        win.on 'ready-to-show', winReadyToShow
        win
    
    saveBounds: (event) -> prefs.set 'bounds', event.sender.getBounds()
        
    quit: => 
        prefs.save()
        w.close() for w in wins()
        electron.app.exit 0
        process.exit 0
        
    showAbout: => about
        img: "#{__dirname}/../bin/about.svg"
        pkg: pkg
        imageWidth:    '250px'
        imageHeight:   '250px'
        imageOffset:   '10px'
        versionOffset: '15px'
        highlight:     '#88f'

#  0000000   00000000   00000000         0000000   000   000
# 000   000  000   000  000   000       000   000  0000  000
# 000000000  00000000   00000000        000   000  000 0 000
# 000   000  000        000        000  000   000  000  0000
# 000   000  000        000        000   0000000   000   000

electron.app.on 'ready', -> app = new App
electron.app.on 'activate', -> app.showWindows()
electron.app.on 'window-all-closed', -> app.quit()
electron.app.on 'open-file', (event, file) -> log "open file #{file}"
        
electron.app.setName pkg.productName

module.exports = App
