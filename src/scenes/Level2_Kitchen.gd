extends Node2D

var cabinet_opened: bool = false
var has_knife: bool = false
var has_bread: bool = false
var has_sandwich: bool = false

@onready var knife_panel = $Knife
@onready var bread_panel = $Bread
@onready var sandwich_panel = $Sandwich
@onready var cabinet_panel = $Cabinet
@onready var hint_btn = $HintBtn
@onready var message_label = $MessageLabel

var hint_texts = [
	"橱柜里似乎有东西...",
	"用小刀和面包可以做成三明治",
	"把三明治拿给门卫看"
]

var current_hint_idx = 0
var msg_timer: float = 0.0

func _ready():
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

func _on_cabinet_pressed():
	if not cabinet_opened:
		cabinet_opened = true
		knife_panel.visible = true
		show_message("你打开了橱柜，找到了一把小刀！")
	else:
		show_message("橱柜已经是开着的了")

func _on_fridge_pressed():
	if not has_bread:
		has_bread = true
		bread_panel.visible = true
		var bread_item = load("res://src/resources/items/bread.tres")
		Global.add_item(bread_item)
		show_message("冰箱里有一块面包！你拿走了它。")
	else:
		show_message("冰箱里已经没有东西了")

func _on_knife_pressed():
	if not has_knife:
		has_knife = true
		knife_panel.visible = false
		var knife_item = load("res://src/resources/items/knife.tres")
		Global.add_item(knife_item)
		show_message("获得：小刀")

func _on_bread_pressed():
	pass

func _on_sandwich_pressed():
	if has_sandwich and Global.has_item("sandwich"):
		show_message("你已经有了三明治!")
	else:
		show_message("需要用小刀+面包组合成三明治")

func _on_hint_pressed():
	if Global.hints_remaining > 0 and current_hint_idx < hint_texts.size():
		show_message(hint_texts[current_hint_idx])
		current_hint_idx += 1
		Global.use_hint()
		hint_btn.text = "提示(" + str(Global.hints_remaining) + ")"

func _on_inventory_updated():
	if Global.has_item("knife") and Global.has_item("bread") and not has_sandwich:
		sandwich_panel.visible = true

func _on_exit_door_pressed():
	if Global.has_item("sandwich"):
		show_message("门卫收下了三明治，让你通过了！")
		await get_tree().create_timer(1.0).timeout
		complete_level()
	else:
		show_message("门卫说：给我弄点吃的我才让你走")
		var tween = create_tween()
		var orig = $ExitDoor.position
		for i in range(3):
			tween.tween_property($ExitDoor, "position", orig + Vector2(10, 0), 0.05)
			tween.tween_property($ExitDoor, "position", orig + Vector2(-10, 0), 0.05)
		tween.tween_property($ExitDoor, "position", orig, 0.05)

func complete_level():
	show_message("恭喜通关！", 2.0)
	await get_tree().create_timer(2.0).timeout
	Global.next_level()
	get_tree().reload_current_scene()
