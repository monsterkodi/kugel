class_name CheatMenu 
extends Menu

func moreMoney(): Wallet.addPrice(2000)

func allPermCards():
    
    var allCards:Array[CardRes] = Card.allRes()

    var cards = get_node("/root/World").currentLevel.cards

    for cardRes in allCards:    
        if cardRes.type == CardRes.CardType.PERMANENT and cardRes.maxLvl > 0:
            if cards.cardLvl(cardRes.name) < cardRes.maxLvl:
                var card = cards.perm.getCard(cardRes.name)
                if card: 
                    card.lvl = clampi(card.lvl+1, 1, cardRes.maxLvl) 
                else:
                    cards.perm.addCard(Card.new(cardRes))
                cards.cardLevel += 1
    
    Post.applyCards.emit()

func allBattleCards():
    
    var allCards:Array[CardRes] = Card.allRes()

    var cards = get_node("/root/World").currentLevel.cards

    for cardRes in allCards:    
        if cardRes.type == CardRes.CardType.BATTLE and cardRes.maxLvl > 0:
            if cards.cardLvl(cardRes.name) < cardRes.maxLvl:
                var card = cards.deck.getCard(cardRes.name)
                if card: 
                    card.lvl = clampi(card.lvl+1, 1, cardRes.maxLvl) 
                else:
                    cards.deck.addCard(Card.new(cardRes))
                cards.cardLevel += 1
    
func appeared():
    
    Utils.childrenWithClass(self, "Button")[0].grab_focus()
    super.appeared()
