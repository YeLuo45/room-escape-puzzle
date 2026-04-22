extends Node

# Item DB - holds all item definitions
# Items are loaded from .tres resource files

const ITEM_PATHS = {
	"key": "res://src/resources/items/key.tres",
	"knife": "res://src/resources/items/knife.tres",
	"bread": "res://src/resources/items/bread.tres",
	"sandwich": "res://src/resources/items/sandwich.tres",
	"diary": "res://src/resources/items/diary.tres",
	"coin": "res://src/resources/items/coin.tres",
	"lever": "res://src/resources/items/lever.tres",
	"torch": "res://src/resources/items/torch.tres",
}

var _items_cache = {}

func _ready():
	# Preload all items
	for item_id in ITEM_PATHS:
		var path = ITEM_PATHS[item_id]
		var item = load(path)
		if item:
			_items_cache[item_id] = item

func get_item(id: String):
	return _items_cache.get(id)
