extends Control

@onready var continue_btn = $VBox/ContinueBtn
@onready var settings_panel = $SettingsPanel
@onready var audio_check = $SettingsPanel/VBox/AudioRow/AudioCheck
@onready var music_check = $SettingsPanel/VBox/MusicRow/MusicCheck

func _ready():
	continue_btn.visible = SaveSystem.has_save()
	settings_panel.visible = false
	audio_check.button_pressed = Global.audio_enabled
	music_check.button_pressed = Global.music_enabled

func _on_start_pressed():
	Global.reset_level_state()
	Global.inventory.clear()
	Global.load_level("Level1_Bedroom")
	get_tree().change_scene_to_file("res://src/scenes/Level1_Bedroom.tscn")

func _on_continue_pressed():
	SaveSystem.load_game()
	Global.reset_level_state()
	get_tree().change_scene_to_file("res://src/scenes/" + Global.current_level + ".tscn")

func _on_settings_pressed():
	settings_panel.visible = true
	audio_check.button_pressed = Global.audio_enabled
	music_check.button_pressed = Global.music_enabled

func _on_audio_toggled(pressed):
	Global.audio_enabled = pressed
	SaveSystem.save_game()

func _on_music_toggled(pressed):
	Global.music_enabled = pressed
	SaveSystem.save_game()

func _on_settings_close_pressed():
	settings_panel.visible = false
