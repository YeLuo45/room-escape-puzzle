extends Node2D

var level_id = ""
var level_name = ""
var hint_texts: Array() = []
var is_completed = false

onready var hud = $HUD
onready var inventory_bar = $InventoryBar

func _ready():
	Global.connect("level_changed", self, "_on_level_changed")
	Global.connect("hint_used", self, "_on_hint_used")
	setup_level()

func _on_level_changed(level_id):
	pass

func _on_hint_used(remaining):
	pass

func setup_level():
	# Override in subclasses
	pass

func show_message(msg, duration: float = 3.0):
	if hud:
		hud.show_message(msg, duration)

func complete_level():
	if is_completed:
		return
	is_completed = true
	
	if hud:
		hud.show_message("恭喜通关！", 2.0)
	
	yield(get_tree().create_timer(2.0), "timeout").timeout
	Global.next_level()
	load_next_scene()

func load_next_scene():
	var next_level = Global.current_level
	get_tree().change_scene("res://src/scenes/" + next_level + ".tscn")
