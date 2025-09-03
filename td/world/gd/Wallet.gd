extends Node

var balance:int = 0
var restoks:int = 0

func _ready():
    
    add_to_group("save")

    #Post.startLevel.connect(startLevel)
    #Post.levelEnd.connect(levelEnd)
    Post.subscribe(self)
    
    #Post.statChanged.emit("balance", balance)
    #Post.statChanged.emit("restoks", restoks)
    
func startLevel():
    
    setBalance(0)

func levelEnd():
    
    setRestoks(restoks+balance)
    setBalance(0)
    
func corpseCollected():
    
    var reward = rewardForCorpseCollected()
    addPrice(reward)
    
func rewardForCorpseCollected():
    
    return 1
    
func buildingBought(building):

    deductPrice(Info.priceForBuilding(building))
    
func addPrice(price):
    
    setBalance(balance + price)
    
func deductPrice(price):
    
    setBalance(balance - price)

func setBalance(newBalance):
    
    balance = max(newBalance, 0)
    Post.statChanged.emit("balance", balance)

func setRestoks(newRestoks):
    
    restoks = max(newRestoks, 0)
    Post.statChanged.emit("restoks", restoks)
    
func on_save(data:Dictionary):

    data.Wallet = {}
    data.Wallet.balance = max(balance, 0)
    data.Wallet.restoks = max(restoks, 0)
    
func on_load(data:Dictionary):
    
    if not data.has("Wallet"): return
    if data.Wallet.has("balance"):
        setBalance(data.Wallet.balance)
    if data.Wallet.has("restoks"):
        setRestoks(data.Wallet.restoks)
