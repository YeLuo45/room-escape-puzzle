extends Node2D

var coin_used: bool = false
var painting_checked: bool = false
var clock_checked: bool = false
var keypad_visible: bool = false
var door_unlocked: bool = false

@onready var keypad_input = $KeypadInput
@onready var keypad_submit = $KeypadSubmit
@onready var keypad_cancel = $KeypadCancel
@onready var hint_btn = $HintBtn
@onready var message_label = $MessageLabel

var hint_texts = [
	"硬币可以放入基座...",
	"钟显示的时间是线索。挂画也有提示。",
	"钟显示9:15，挂画提示3-1-5顺序。密码是915"
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

func _on_pedestal_pressed():
	if not coin_used and Global.has_item("coin"):
		coin_used = true
		# Remove coin from inventory - find it first
		for item in Global.inventory:
			if item and item.id == "coin":
				Global.remove_item(item)
				break
		show_message("硬币放入基座！墙上钟表亮了起来，显示9:15")
		clock_checked = true
	elif coin_used:
		show_message("基座已经启动了")
	else:
		show_message("基座需要硬币才能启动")

func _on_painting_pressed():
	painting_checked = true
	show_message("挂画后面写着：'时间的顺序，315'。这似乎是密码提示...")

func _on_clock_pressed():
	if coin_used:
		clock_checked = true
		show_message("钟显示 9:15。短针指向9，长针指向1和5")
	else:
		show_message("钟是静止的，需要先启动基座")

func _on_keypad_pressed():
	if door_unlocked:
		show_message("门已经打开了！")
		return
	if not coin_used:
		show_message("键盘没有电源...")
		return
	keypad_visible = true
	keypad_input.visible = true
	keypad_submit.visible = true
	keypad_cancel.visible = true
	keypad_input.text = ""
	keypad_input.grab_focus()

func _on_keypad_cancel_pressed():
	keypad_visible = false
	keypad_input.visible = false
	keypad_submit.visible = false
	keypad_cancel.visible = false

func _on_keypad_submit_pressed():
	var entered = keypad_input.text.strip_edges()
	if entered == "915":
		door_unlocked = true
		keypad_visible = false
		keypad_input.visible = false
		keypad_submit.visible = false
		keypad_cancel.visible = false
		show_message("密码正确！门锁打开了！")
		$ExitDoor.tooltip_text = "出口大门(已解锁)"
	else:
		show_message("密码错误！")
		var tween = create_tween()
		var orig = keypad_input.position
		for i in range(3):
			tween.tween_property(keypad_input, "position:x", orig.x + 10, 0.05)
			tween.tween_property(keypad_input, "position:x", orig.x - 10, 0.05)
		tween.tween_property(keypad_input, "position:x", orig.x, 0.05)
		keypad_input.text = ""

func _on_hint_pressed():
	if Global.hints_remaining > 0 and current_hint_idx < hint_texts.size():
		show_message(hint_texts[current_hint_idx])
		current_hint_idx += 1
		Global.use_hint()
		hint_btn.text = "提示(" + str(Global.hints_remaining) + ")"

func _on_inventory_updated():
	pass

func _on_exit_door_pressed():
	if door_unlocked:
		show_message("恭喜你逃出了房间！游戏通关！", 4.0)
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")
	else:
		show_message("门是锁着的，需要密码")
		var tween = create_tween()
		var orig = $ExitDoor.position
		for i in range(3):
			tween.tween_property($ExitDoor, "position", orig + Vector2(10, 0), 0.05)
			tween.tween_property($ExitDoor, "position", orig + Vector2(-10, 0), 0.05)
		tween.tween_property($ExitDoor, "position", orig, 0.05)
