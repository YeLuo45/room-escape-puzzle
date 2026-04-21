extends Node2D

var drawer_opened: bool = false
var has_key: bool = false

@onready var key_panel = $Key
@onready var drawer_panel = $Drawer
@onready var door_panel = $Door
@onready var hint_btn = $HintBtn
@onready var message_label = $MessageLabel

var hint_texts = [
	"床头柜似乎可以打开...",
	"钥匙可能藏在抽屉里",
	"用钥匙打开门即可通关"
]

var current_hint_idx = 0
var msg_timer: float = 0.0

func _ready():
	level_id = "Level1_Bedroom"
	level_name = "卧室"
	hint_btn.text = "提示(" + str(Global.hints_remaining) + ")"
	
	Global.inventory_updated.connect(_on_inventory_updated)

func _process(delta):
	if msg_timer > 0:
		msg_timer -= delta
		if msg_timer <= 0:
			message_label.visible = false

func show_message(msg: String, duration: float = 3.0):
	message_label.text = msg
	message_label.visible = true
	msg_timer = duration

func _on_drawer_pressed():
	if not drawer_opened:
		drawer_opened = true
		key_panel.visible = true
		show_message("你打开了抽屉，发现了一把钥匙！")
	else:
		show_message("抽屉已经是开着的了")

func _on_key_pressed():
	if not has_key:
		has_key = true
		key_panel.visible = false
		var key_item = preload("res://src/resources/items/key.tres")
		Global.add_item(key_item)
		show_message("获得：钥匙")

func _on_door_pressed():
	if Global.has_item("key"):
		show_message("钥匙打开了门！")
		await get_tree().create_timer(1.0).timeout
		complete_level()
	else:
		show_message("门锁着，需要找到钥匙")
		# Shake effect
		var tween = create_tween()
		var orig = door_panel.position
		for i in range(3):
			tween.tween_property(door_panel, "position", orig + Vector2(10, 0), 0.05)
			tween.tween_property(door_panel, "position", orig + Vector2(-10, 0), 0.05)
		tween.tween_property(door_panel, "position", orig, 0.05)

func _on_hint_pressed():
	if Global.hints_remaining > 0 and current_hint_idx < hint_texts.size():
		show_message(hint_texts[current_hint_idx])
		current_hint_idx += 1
		Global.use_hint()
		hint_btn.text = "提示(" + str(Global.hints_remaining) + ")"

func _on_inventory_updated():
	pass # Debug: print("Inventory: ", Global.inventory)

func complete_level():
	show_message("恭喜通关！", 2.0)
	await get_tree().create_timer(2.0).timeout
	Global.next_level()
	get_tree().change_scene_to_file("res://src/scenes/" + Global.current_level + ".tscn")
