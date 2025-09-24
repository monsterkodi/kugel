class_name BuildButton 
extends CardButton

const SCENE_SIZE = Vector2i(int(150*0.8),int(125*0.8))

func setBuilding(building:String):
    
    name = building
    sceneViewport.setBuilding(building)
    setSize(SCENE_SIZE)
    
    var price = Info.priceForBuilding(building)
    if price:
        
        if get_node("/root/World/BattleCards").countCards(building):
            text = "card"
        else:
            text = str(price)

func setDots(numDots): pass
