extends Node

var balance:int = 0

func _ready():
    
    Post.buildingBuild.connect(deductPriceForBuilding)
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
    
    return 10
    
func addPrice(price):
    
    setBalance(balance + price)
    
func deductPrice(price):
    
    setBalance(balance - price)

func setBalance(newBalance):
    
    balance = newBalance
    Log.log("balance", balance)
    Post.statChanged.emit("balance", balance)
    
func on_save(data:Dictionary):

    data.Wallet = {}
    data.Wallet.balance = balance
    
func on_load(data:Dictionary):
    
    if not data.has("Wallet"): return
    
    setBalance(data.Wallet.balance)
