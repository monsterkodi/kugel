class_name CheatMenu 
extends Menu

func moreMoney(): Wallet.addPrice(2000)

func allPermCards():
    
    var allCards:Array[CardRes] = Card.allRes()

    for cardRes in allCards:    
        if cardRes.type == CardRes.CardType.PERMANENT and cardRes.maxLvl > 0:
            if Info.cardLvl(cardRes.name) < cardRes.maxLvl:
                var card = %Player.perm.getCard(cardRes.name)
                if card: 
                    card.lvl = clampi(card.lvl+1, 1, cardRes.maxLvl) 
                else:
                    %Player.perm.addCard(Card.new(cardRes))
                %Player.cardLevel += 1
    
    Post.applyCards.emit()

func allBattleCards():
    
    var allCards:Array[CardRes] = Card.allRes()

    for cardRes in allCards:    
        if cardRes.type == CardRes.CardType.BATTLE and cardRes.maxLvl > 0:
            if Info.cardLvl(cardRes.name) < cardRes.maxLvl:
                var card = %Player.deck.getCard(cardRes.name)
                if card: 
                    card.lvl = clampi(card.lvl+1, 1, cardRes.maxLvl) 
                else:
                    %Player.deck.addCard(Card.new(cardRes))
                %Player.cardLevel += 1
    
func appeared():
    
    Utils.childrenWithClass(self, "Button")[0].grab_focus()
    super.appeared()
