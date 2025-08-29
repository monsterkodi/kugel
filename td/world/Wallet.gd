extends Node

var balance:int = 0

func _ready():
    
    add_to_group("save")
    Post.buildingPlaced.connect(deductPriceForBuilding)
    Post.corpseCollected.connect(addRewardForCorpseCollected)
    Post.statChanged.emit("balance", balance)
    
func addRewardForCorpseCollected():
    
    var reward = rewardForCorpseCollected()
    addPrice(reward)
    
func rewardForCorpseCollected():
    
    return 1
    
func deductPriceForBuilding(building):

    var price = priceForBuilding(building)
    deductPrice(price)
    
func priceForBuilding(building):
    #Log.log("priceForBuilding", building)
    match building:
        "Laser":   return 40
        #"Shield":  return 20
        "Turret":  return 10
        "Bouncer": return 5
        "Pole":    return 2
        _:         return 0
    
func addPrice(price):
    
    setBalance(balance + price)
    
func deductPrice(price):
    
    setBalance(balance - price)

func setBalance(newBalance):
    
    balance = max(newBalance, 0)
    #Log.log("balance", balance)
    Post.statChanged.emit("balance", balance)
    
func on_save(data:Dictionary):

    data.Wallet = {}
    data.Wallet.balance = max(balance, 0)
    
func on_load(data:Dictionary):
    
    if not data.has("Wallet"): return
    
    setBalance(data.Wallet.balance)
