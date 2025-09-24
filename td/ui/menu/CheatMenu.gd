class_name CheatMenu 
extends Menu

func moreMoney(): Wallet.addPrice(1000)

func allPermCards():
    
    var allCards:Array[CardRes] = Card.allRes()

    for cardRes in allCards:    
        if cardRes.type == CardRes.CardType.PERMANENT and cardRes.maxLvl > 0:
            if Info.cardLvl(cardRes.name) < cardRes.maxLvl:
                %Player.perm.addCard(Card.new(cardRes))
                %Player.cardLevel += 1
    
    Post.applyCards.emit()

func allBattleCards():
    
    var allCards:Array[CardRes] = Card.allRes()

    for cardRes in allCards:    
        if cardRes.type == CardRes.CardType.BATTLE and cardRes.maxLvl > 0:
            if Info.cardLvl(cardRes.name) < cardRes.maxLvl:
                %Player.deck.addCard(Card.new(cardRes))
                %Player.cardLevel += 1
    
func appeared():
    
    Utils.childrenWithClass(self, "Button")[0].grab_focus()
    super.appeared()
