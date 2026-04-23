extends CanvasLayer

onready var level_name = $LevelName
onready var hint_btn = $HintBtn
onready var message_label = $MessageLabel

var hint_texts: Array() = []
var current_message_time = 0.0

func _ready():
	level_name.text = Global.get_level_display_name(Global.current_level)
	hint_btn.text = "提示(" + str(Global.hints_remaining) + ")"

	Global.connect("level_changed", self, "_on_level_changed")
	Global.connect("hint_used", self, "_on_hint_used")

func _process(delta):
	if current_message_time > 0:
		current_message_time -= delta
		if current_message_time <= 0:
			message_label.text = ""

func set_hints(hints):
	hint_texts = hints

func show_message(msg, duration: float = 3.0):
	message_label.text = msg
	message_label.visible = true
	current_message_time = duration

func _on_level_changed(level_id):
	level_name.text = Global.get_level_display_name(level_id)
	hint_btn.text = "提示(" + str(Global.hints_remaining) + ")"

func _on_hint_used(remaining):
	hint_btn.text = "提示(" + str(remaining) + ")"

func _on_hint_pressed():
	if Global.hints_remaining > 0 and hint_texts.size() > 0:
		var hint_idx = hint_texts.size() - Global.hints_remaining
		if hint_idx < hint_texts.size():
			show_message(hint_texts[hint_idx])
			Global.emit_signal("use_hint")
