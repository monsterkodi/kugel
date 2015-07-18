###
000  000   000  00000000   0000000 
000  0000  000  000       000   000
000  000 0 000  000000    000   000
000  000  0000  000       000   000
000  000   000  000        0000000 
###

Window = require './knix/window'
def    = require './knix/def'
log    = require './knix/log'
Stage  = require './knix/stage'

class Info extends Window
    
    @value: {}
    
    init: (cfg, defs) =>        
    
        cfg = def cfg, defs
        
        children = []
        
        for key, value of Info.value
            children.push
                elem: 'div'
                children: [
                        elem:     'span'
                        text:     key
                        style:
                            display:  'inline-block'
                            width:    '80px'
                            color:    'gray'
                    ,
                        elem: 'span'
                        id:   key
                        text: value
                    ]

        super cfg,
            title    : ' '
            id       : 'info'
            resize   : 'horizontal'
            width    : Stage.size().width
            children : children
            
        requestAnimationFrame @refresh

    @toggle: -> if $('info') then $('info').widget.close() else new Info
        
    refresh: =>
        for key, value of Info.value
            $(key).widget.setText value
        requestAnimationFrame @refresh
    
module.exports = Info
