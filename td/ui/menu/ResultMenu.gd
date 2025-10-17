class_name ResultMenu
extends Menu

const CARD_SIZE : Vector2i = Vector2i(300,225)

func appear():
    
    var levelName = get_node("/root/World").currentLevel.name
    
    %Retry.grab_focus()
    
    assert(Saver.savegame.data.has("Level"))
    assert(Saver.savegame.data.Level.has(levelName))
    
    var data = Saver.savegame.data.Level[levelName]
    var hs = data.highscore
    
    %ScoreValue.text       = str(data.lastScore)
    %TimeValue.text        = Utils.timeStr(Info.gameTime)
    
    var trophyLimit = Info.trophyLimitsForLevel(levelName)
    
    %ProgressBar.max_value = trophyLimit[2]
    %ProgressBar.value     = clampi(data.lastScore, 0, %ProgressBar.max_value)
    
    %CardButton1.setCardWithName(Card.TrophyBronce)
    %CardButton2.setCardWithName(Card.TrophySilver)
    %CardButton3.setCardWithName(Card.TrophyGold)
    
    %LockValue1.text = str(trophyLimit[0])
    %LockValue2.text = str(trophyLimit[1])
    %LockValue3.text = str(trophyLimit[2])
    
    if data.lastScore >= trophyLimit[0]: %LockValue1.add_theme_color_override("font_color", Color(1,0,0))
    if data.lastScore >= trophyLimit[1]: %LockValue2.add_theme_color_override("font_color", Color(1,0,0))
    if data.lastScore >= trophyLimit[2]: %LockValue3.add_theme_color_override("font_color", Color(1,0,0))
    
    %CardButton1.setSize(CARD_SIZE)
    %CardButton2.setSize(CARD_SIZE)
    %CardButton3.setSize(CARD_SIZE)
    
    super.appear()

func back():
    
    Post.clearLevel.emit()
    super.back()
    
func onRetry():
    
    Post.clearLevel.emit()
    Post.retryLevel.emit()

func onMainMenu():
    
    Post.clearLevel.emit()
    Post.mainMenu.emit()
