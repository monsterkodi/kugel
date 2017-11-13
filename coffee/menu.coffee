# 00     00  00000000  000   000  000   000
# 000   000  000       0000  000  000   000
# 000000000  0000000   000 0 000  000   000
# 000 0 000  000       000  0000  000   000
# 000   000  00000000  000   000   0000000 

{ post, log }  = require 'kxk'

pkg      = require '../package.json'
electron = require 'electron'

class Menu
    
    @init: (app) -> 
        
        electron.Menu.setApplicationMenu electron.Menu.buildFromTemplate [
            
            # 000   000  000   000   0000000   00000000  000      
            # 000  000   000   000  000        000       000      
            # 0000000    000   000  000  0000  0000000   000      
            # 000  000   000   000  000   000  000       000      
            # 000   000   0000000    0000000   00000000  0000000  
            
            label: pkg.name, submenu: [     
                { label: "About #{pkg.name}",   accelerator: 'command+,',       click: app.showAbout}
                { type:  'separator'}
                { label: "Hide #{pkg.name}",    accelerator: 'command+h',       role: 'hide'}
                { label: 'Hide Others',         accelerator: 'command+alt+h',   role: 'hideothers'}
                { type:  'separator'}
                { label: 'Quit',                accelerator: 'command+q',       click: app.quit}
            ]
        ,
            # 000   000  000  000   000  0000000     0000000   000   000
            # 000 0 000  000  0000  000  000   000  000   000  000 0 000
            # 000000000  000  000 0 000  000   000  000   000  000000000
            # 000   000  000  000  0000  000   000  000   000  000   000
            # 00     00  000  000   000  0000000     0000000   00     00
            
            label: 'Window', submenu: [
                { label: 'Minimize Window',    accelerator: 'command+alt+shift+m', click: (i,win) -> win?.minimize()}
                { label: 'Maximize Window',    accelerator: 'command+alt+m',       click: (i,win) -> 
                    if win?.isMaximized() then win?.unmaximize() 
                    else win?.maximize()
                }
                { type:  'separator'}
                { label: 'Reload Window',      accelerator: 'Ctrl+Alt+Cmd+L',   click: (i,win) -> app.reloadWin win}
                { label: 'Toggle DevTools',    accelerator: 'Cmd+Alt+I',        click: (i,win) -> win?.webContents.toggleDevTools()}
            ]
        ,        
            # 000   000  00000000  000      00000000 
            # 000   000  000       000      000   000
            # 000000000  0000000   000      00000000 
            # 000   000  000       000      000      
            # 000   000  00000000  0000000  000      
            
            label: 'Help', role: 'help', submenu: []            
        ]

module.exports = Menu
