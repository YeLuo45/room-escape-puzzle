extends Node2D

var level_id: String = ""
var level_name: String = ""
var hint_texts: Array[String] = []
var is_completed: bool = false

@onready var hud = $HUD
@onready var inventory_bar = $InventoryBar

func _ready():
	setup_level()

func setup_level():
	# Override in subclasses
	pass

func show_message(msg: String, duration: float = 3.0):
	if hud:
		hud.show_message(msg, duration)

func complete_level():
	if is_completed:
		return
	is_completed = true
	
	if hud:
		hud.show_message("恭喜通关！", 2.0)
	
	await get_tree().create_timer(2.0).timeout
	Global.next_level()
	load_next_scene()

func load_next_scene():
	var next_level = Global.current_level
	get_tree().change_scene_to_file("res://src/scenes/" + next_level + ".tscn")
