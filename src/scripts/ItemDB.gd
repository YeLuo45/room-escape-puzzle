extends Node

const ALL_ITEMS: Array[Item] = [
	preload("res://src/resources/items/key.tres"),
	preload("res://src/resources/items/knife.tres"),
	preload("res://src/resources/items/bread.tres"),
	preload("res://src/resources/items/sandwich.tres"),
	preload("res://src/resources/items/diary.tres"),
	preload("res://src/resources/items/coin.tres"),
	preload("res://src/resources/items/lever.tres"),
	preload("res://src/resources/items/torch.tres"),
]

static func get_item(id: String) -> Item:
	for item in ALL_ITEMS:
		if item.id == id:
			return item
	return null
