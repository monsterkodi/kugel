class_name CheatMenu 
extends Menu

func moreMoney(): Wallet.addPrice(1000)

func allPermCards():
    
    var allCards:Array[CardRes] = Utils.allCardRes()

    for cardRes in allCards:    
        if cardRes.type == CardRes.CardType.PERMANENT and cardRes.maxNum > 0:
            var owned = Info.numberOfCardsOwned(cardRes.name)
            if owned < cardRes.maxNum:
                %Player.perm.addCard(Card.new(cardRes))
                %Player.cardLevel += 1
    
    Post.applyCards.emit()

func allBattleCards():
    
    var allCards:Array[CardRes] = Utils.allCardRes()

    for cardRes in allCards:    
        if cardRes.type == CardRes.CardType.BATTLE and cardRes.maxNum > 0:
            var owned = Info.numberOfCardsOwned(cardRes.name)
            if owned < cardRes.maxNum:
                %Player.deck.addCard(Card.new(cardRes))
                %Player.cardLevel += 1
    
func appeared():
    
    Utils.childrenWithClass(self, "Button")[0].grab_focus()
    super.appeared()
