###
 0000000   000   000  0000000    000   0000000 
000   000  000   000  000   000  000  000   000
000000000  000   000  000   000  000  000   000
000   000  000   000  000   000  000  000   000
000   000   0000000   0000000    000   0000000 
###

def = require './def' 

class Audio

    @init: => 
        @context = new (window.AudioContext || window.webkitAudioContext)()
        @master = @gain
            gain: 1.0
        @master.connect @context.destination
                
    @filter: (cfg) =>

        cfg = def cfg,
            frequency    : 440
            minFrequency : 100
            maxFrequency : 12000
            detune       : 0
            minDetune    : -1000
            maxDetune    : 1000
            gain         : 1
            minGain      : 0
            maxGain      : 1
            Q            : 1
            minQ         : 0.0
            maxQ         : 50
            filter       : 'bandpass'

        filter = @context.createBiquadFilter()
        filter.frequency.value = cfg.frequency # in Hz
        filter.detune.value    = cfg.detune # in cnt
        filter.Q.value         = cfg.Q
        filter.type            = cfg.filter
        [ filter, cfg ]

    @delay: (cfg) =>
        
        cfg = def cfg,
            delay    : 0.005
            maxDelay : 5.0
            minDelay : 0.0
        
        delay = @context.createDelay(cfg.maxDelay)
        delay.delayTime.value = cfg.delay
        [ delay, cfg ]

    @oscillator: (cfg) =>

        cfg = def cfg,
            frequency    : 0
            minFrequency : 0
            maxFrequency : 14000

        oscillator = @context.createOscillator()
        oscillator.frequency.value = cfg.frequency # in Hz
        oscillator.start 0
        [ oscillator, cfg ]

    @gain: (cfg) =>

        gain = @context.createGain()
        gain.gain.value = cfg.gain? and cfg.gain or 1.0
        gain

    @analyser: (cfg) =>

        cfg = def cfg,
            minDecibels   : -90 
            maxDecibels   : -10 
            smoothingTime : 0.85 
            fftSize       : 2048

        analyser = @context.createAnalyser()
        analyser.minDecibels = cfg.minDecibels
        analyser.maxDecibels = cfg.maxDecibels
        analyser.smoothingTimeConstant = cfg.smoothingTime
        analyser.fftSize = cfg.fftSize
        [ analyser, cfg ]
    
    @destroy: (node) =>
        node.disconnect()
        node.stop?()
        undefined
        
module.exports = Audio
