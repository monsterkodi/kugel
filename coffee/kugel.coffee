
# 000   000  000   000   0000000   00000000  000      
# 000  000   000   000  000        000       000      
# 0000000    000   000  000  0000  0000000   000      
# 000  000   000   000  000   000  000       000      
# 000   000   0000000    0000000   00000000  0000000  

{ keyinfo, stopEvent, post, prefs, sw, sh, pos, log, $, _ } = require 'kxk'

World = require './world'
Pad   = require './pad'

class Kugel

    constructor: (element) ->

        prefs.init()
        
        @element =$ element
        
        @focus()
        
        @element.addEventListener 'keydown', @onKeyDown
        @element.addEventListener 'keyup',   @onKeyUp
                
        window.onresize = @onResize
        
        @world = new World @element
        
        @pad = new Pad()       
        @pad.addListener 'buttondown', (event) -> log 'buttondown', event
        # @pad.addListener 'buttonup',   (event) -> log 'buttonup', event
        # @pad.addListener 'stick',      (event) -> log 'stick', event
        
    onResize: => 

        post.emit 'resize', pos sw(), sh()
        @world.setBounds sw(), sh()
                
    # 000   000  00000000  000   000  
    # 000  000   000        000 000   
    # 0000000    0000000     00000    
    # 000  000   000          000     
    # 000   000  00000000     000     
    
    focus: -> @element.focus()
    
    onKeyDown: (event) =>
        
        {mod, key, combo, char} = keyinfo.forEvent event
        log mod, key, combo, char

    onKeyUp: (event) =>
        
        {mod, key, combo, char} = keyinfo.forEvent event
                        
module.exports = Kugel
