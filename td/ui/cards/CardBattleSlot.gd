class_name CardBattleSlot
extends Node3D

const CARD_SIZE   = Vector2i(100,92)

func _ready(): 

    %Card1.setCard(Card.new(Utils.cardResWithName(Card.Shield)))
    %Card1.text = ""
    %Card1.setSize(CARD_SIZE)        

    %Card2.setCard(Card.new(Utils.cardResWithName(Card.Bouncer)))
    %Card2.text = ""
    %Card2.setSize(CARD_SIZE)        

    %Card3.setCard(Card.new(Utils.cardResWithName(Card.Laser)))
    %Card3.text = ""
    %Card3.setSize(CARD_SIZE)        
