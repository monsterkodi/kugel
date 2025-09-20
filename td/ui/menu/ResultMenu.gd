class_name ResultMenu
extends Menu

const CARD_SIZE : Vector2i = Vector2i(300,225)

func appear():
    
    %Buttons.get_child(0).grab_focus()
    
    %ScoreValue.text       = str(Stats.numEnemiesSpawned)
    %TimeValue.text        = Utils.timeStr(Info.gameTime)
    
    %ProgressBar.value     = Info.highscoreForCurrentLevel()
    %ProgressBar.max_value = Card.Unlock[Card.Sniper]
    
    %CardButton1.setCardWithName(Card.SlotRing)
    %CardButton2.setCardWithName(Card.Laser)
    %CardButton3.setCardWithName(Card.Shield)
    %CardButton4.setCardWithName(Card.Sniper)
    
    %LockValue1.text = str(Card.Unlock[Card.SlotRing])
    %LockValue2.text = str(Card.Unlock[Card.Laser])
    %LockValue3.text = str(Card.Unlock[Card.Shield])
    %LockValue4.text = str(Card.Unlock[Card.Sniper])
    
    var hs = Info.highscoreForCurrentLevel()
    
    if hs >= Card.Unlock[Card.SlotRing]: %LockValue1.add_theme_color_override("font_color", Color(1,0,0))
    if hs >= Card.Unlock[Card.Laser]:    %LockValue2.add_theme_color_override("font_color", Color(1,0,0))
    if hs >= Card.Unlock[Card.Shield]:   %LockValue3.add_theme_color_override("font_color", Color(1,0,0))
    if hs >= Card.Unlock[Card.Sniper]:   %LockValue4.add_theme_color_override("font_color", Color(1,0,0))
    
    %CardButton1.setSize(CARD_SIZE)
    %CardButton2.setSize(CARD_SIZE)
    %CardButton3.setSize(CARD_SIZE)
    %CardButton4.setSize(CARD_SIZE)
    
    super.appear()
    
func onRetry():
    
    %MenuHandler.appear(%HandChooser)

func onMainMenu():
    
    %MenuHandler.appear(%MainMenu)
