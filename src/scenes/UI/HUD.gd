extends CanvasLayer

@onready var level_name = $LevelName
@onready var hint_btn = $HintBtn
@onready var message_label = $MessageLabel

var hint_texts: Array[String] = []
var current_message_time: float = 0.0

func _ready():
	level_name.text = Global.get_level_display_name(Global.current_level)
	hint_btn.text = "提示(" + str(Global.hints_remaining) + ")"
	
	Global.level_changed.connect(_on_level_changed)
	Global.hint_used.connect(_on_hint_used)

func _process(delta):
	if current_message_time > 0:
		current_message_time -= delta
		if current_message_time <= 0:
			message_label.text = ""

func set_hints(hints: Array[String]):
	hint_texts = hints

func show_message(msg: String, duration: float = 3.0):
	message_label.text = msg
	current_message_time = duration

func _on_level_changed(level_id: String):
	level_name.text = Global.get_level_display_name(level_id)
	hint_btn.text = "提示(" + str(Global.hints_remaining) + ")"

func _on_hint_used(remaining: int):
	hint_btn.text = "提示(" + str(remaining) + ")"

func _on_hint_pressed():
	if Global.hints_remaining > 0 and hint_texts.size() > 0:
		var hint_idx = hint_texts.size() - Global.hints_remaining
		if hint_idx < hint_texts.size():
			show_message(hint_texts[hint_idx])
			Global.use_hint()
