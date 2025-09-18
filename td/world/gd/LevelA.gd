class_name LevelA
extends Level

func start():
    
    super.start()
    %Clock.start()
    
func applyCards():
    
    var rings = Info.countPermCards(Card.SlotRing)
    Log.log("rings", rings)
    %SlotRing1.visible = true
    %SlotRing2.visible = (rings >= 1)
    %SlotRing3.visible = (rings >= 2)
    %SlotRing4.visible = (rings >= 3)
    %SlotRing5.visible = (rings >= 4)
    %SlotRing6.visible = (rings >= 5)
    
