class_name ResultMenu
extends Menu

const CARD_SIZE : Vector2i = Vector2i(300,225)

func appear():
    
    var level = get_node("/root/World").currentLevel
    var hs = Info.highscoreForCurrentLevel()
    
    %Retry.grab_focus()
    
    var data = Saver.savegame.data.Level[level.name]
    
    %ScoreValue.text       = str(data.lastScore)
    %TimeValue.text        = Utils.timeStr(Info.gameTime)
    
    %ProgressBar.max_value = level.trophyLimit[2]
    %ProgressBar.value     = clampi(data.lastScore, 0, %ProgressBar.max_value)
    
    %CardButton1.setCardWithName(Card.TrophyBronce)
    %CardButton2.setCardWithName(Card.TrophySilver)
    %CardButton3.setCardWithName(Card.TrophyGold)
    
    %LockValue1.text = str(level.trophyLimit[0])
    %LockValue2.text = str(level.trophyLimit[1])
    %LockValue3.text = str(level.trophyLimit[2])
    
    if data.lastScore >= level.trophyLimit[0]: %LockValue1.add_theme_color_override("font_color", Color(1,0,0))
    if data.lastScore >= level.trophyLimit[1]: %LockValue2.add_theme_color_override("font_color", Color(1,0,0))
    if data.lastScore >= level.trophyLimit[2]: %LockValue3.add_theme_color_override("font_color", Color(1,0,0))
    
    %CardButton1.setSize(CARD_SIZE)
    %CardButton2.setSize(CARD_SIZE)
    %CardButton3.setSize(CARD_SIZE)
    
    super.appear()
    
func onRetry():
    
    Post.retryLevel.emit()

func onMainMenu():
    
    Post.mainMenu.emit()
