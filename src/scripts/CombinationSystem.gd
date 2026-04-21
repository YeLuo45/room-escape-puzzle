extends Node

# Combination recipes: "item_a_id + item_b_id" -> result_item_id
var recipes: Dictionary = {
	"knife + bread": "sandwich",
	"torch + lever": "lit_lever",
}

static func get_recipe_key(id_a: String, id_b: String) -> String:
	if id_a < id_b:
		return id_a + " + " + id_b
	else:
		return id_b + " + " + id_a

func can_combine(item_a: Item, item_b: Item) -> bool:
	var key = get_recipe_key(item_a.id, item_b.id)
	return recipes.has(key)

func try_combine(item_a: Item, item_b: Item) -> Item:
	var key = get_recipe_key(item_a.id, item_b.id)
	if recipes.has(key):
		return ItemDB.get_item(recipes[key])
	return null
