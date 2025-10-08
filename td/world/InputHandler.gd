class_name InputHandler
extends Node

# for this to work it has to be the last node in the root of the scene tree
# see: https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html#doc-inputevent

var repeatActions = ["ui_up", "ui_down", "ui_left", "ui_right"]
var repeatTimers = {}

const REPEAT_DELAY    = 0.5
const REPEAT_INTERVAL = 0.1

func _input(event: InputEvent):
    
    if event is InputEventKey:
        if event.is_echo():
            get_viewport().set_input_as_handled()
            return
            
    if event is InputEventAction: return
        
    for action in repeatActions:
        if event.is_action_pressed(action):
            get_viewport().set_input_as_handled()
            if event is InputEventJoypadMotion and %BuildMenu.visible:
                return
            #Log.log("pressed", action)
            if not repeatTimers.has(action):
                repeatTimers[action] = Timer.new()
                repeatTimers[action].one_shot = true
                repeatTimers[action].ignore_time_scale = true
                repeatTimers[action].timeout.connect(fakeKeyRepeat.bind(action))
                self.add_child(repeatTimers[action])
                repeatTimers[action].start(REPEAT_DELAY)
                emitAction(action)
            else:
                if get_tree().paused:
                    Log.log("handled", action, event.get_class())
                else:
                    stopActionRepeat(action)
                
        elif event.is_action_released(action):
            #Log.log("released", action)
            stopActionRepeat(action)
        
func stopActionRepeat(action):
    
    if repeatTimers.has(action):
        repeatTimers[action].stop()
        self.remove_child(repeatTimers[action])
        repeatTimers[action].free()
        repeatTimers.erase(action)

func fakeKeyRepeat(action):
    
    if repeatTimers.has(action):
        #Log.log("repeat", action)
        emitAction(action)
        repeatTimers[action].start(REPEAT_INTERVAL)
        
        #await get_tree().process_frame
        #event.pressed = false
        #Input.parse_input_event(event)

func emitAction(action):
    
    var event = InputEventAction.new()
    event.action  = action
    event.pressed = true
    Input.parse_input_event(event)
    
