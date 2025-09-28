class_name ResultMenu
extends Menu

const CARD_SIZE : Vector2i = Vector2i(300,225)

func appear():
    
    %Buttons.get_child(0).grab_focus()
    
    %ScoreValue.text       = str(Stats.numEnemiesSpawned)
    %TimeValue.text        = Utils.timeStr(Info.gameTime)
    
    Log.log(Info.highscoreForCurrentLevel(), Card.Unlock[Card.TrophyGold])
    %ProgressBar.max_value = Card.Unlock[Card.TrophyGold]
    %ProgressBar.value     = clampi(Info.highscoreForCurrentLevel(), 0, %ProgressBar.max_value)
    
    %CardButton1.setCardWithName(Card.TrophyBronce)
    %CardButton2.setCardWithName(Card.TrophySilver)
    %CardButton3.setCardWithName(Card.TrophyGold)
    
    %LockValue1.text = str(Card.Unlock[Card.TrophyBronce])
    %LockValue2.text = str(Card.Unlock[Card.TrophySilver])
    %LockValue3.text = str(Card.Unlock[Card.TrophyGold])
    
    if Info.isUnlockedCard(Card.TrophyBronce): %LockValue1.add_theme_color_override("font_color", Color(1,0,0))
    if Info.isUnlockedCard(Card.TrophySilver): %LockValue2.add_theme_color_override("font_color", Color(1,0,0))
    if Info.isUnlockedCard(Card.TrophyGold):   %LockValue3.add_theme_color_override("font_color", Color(1,0,0))
    
    %CardButton1.setSize(CARD_SIZE)
    %CardButton2.setSize(CARD_SIZE)
    %CardButton3.setSize(CARD_SIZE)
    
    super.appear()
    
func onRetry():
    
    Post.retryLevel.emit()

func onMainMenu():
    
    %MenuHandler.appear(%MainMenu)
