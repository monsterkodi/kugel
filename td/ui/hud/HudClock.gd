class_name HudClock
extends Control

static var showClock : bool = false

func _process(delta: float):
    
    %Clock.text = Utils.timeStr(Info.gameTime)
    %ClockPanel.visible = HudClock.showClock
