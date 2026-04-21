extends Node2D

# Solution: Pull lever3, lever1, lever2 (order matters!)
var lever_states: Array[bool] = [false, false, false]
var correct_sequence: Array[int] = [2, 0, 1]  # lever3, lever1, lever2 (0-indexed)
var current_step: int = 0
var torch_collected: bool = false
var chest_opened: bool = false

@onready var lever1_panel = $Lever1
@onready var lever2_panel = $Lever2
@onready var lever3_panel = $Lever3
@onready var dark_overlay = $DarkOverlay
@onready var hint_btn = $HintBtn
@onready var message_label = $MessageLabel

var hint_texts = [
	"地下室很黑，需要火把照明...",
	"先拉对顺序的控制杆：第3个、第1个、第2个",
	"按顺序拉杆后，箱子和按钮会解锁"
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

func _on_lever1_pressed():
	_toggle_lever(0, lever1_panel, "杆 #1")

func _on_lever2_pressed():
	_toggle_lever(1, lever2_panel, "杆 #2")

func _on_lever3_pressed():
	_toggle_lever(2, lever3_panel, "杆 #3")

func _toggle_lever(idx: int, panel: Panel, name: String):
	if not Global.has_item("torch"):
		show_message("太黑了，看不清...")
		return
	
	lever_states[idx] = not lever_states[idx]
	
	# Update visual
	var style = preload("res://src/assets/sprites/leaver_on.tres") if lever_states[idx] else preload("res://src/assets/sprites/leaver_off.tres")
	if lever_states[idx]:
		show_message(name + " 已拉下！", 1.0)
	else:
		show_message(name + " 已复位！", 1.0)
	
	# Check sequence
	if lever_states[idx]:
		if idx == correct_sequence[current_step]:
			current_step += 1
			if current_step >= correct_sequence.size():
				show_message("所有机关解锁！")
				chest_opened = true
				$Chest.tooltip_text = "箱子(已解锁)"
		else:
			# Wrong order, reset
			show_message("顺序不对，所有杆都复位了！")
			_reset_levers()
			current_step = 0

func _reset_levers():
	for i in range(3):
		lever_states[i] = false

func _on_chest_pressed():
	if chest_opened:
		if not torch_collected:
			torch_collected = true
			var torch_item = preload("res://src/resources/items/torch.tres")
			Global.add_item(torch_item)
			show_message("获得：火把！地下室亮起来了！")
			dark_overlay.visible = false
		else:
			show_message("箱子里已经没有东西了")
	elif not Global.has_item("torch"):
		show_message("太黑了，看不清箱子里有什么...")
	else:
		show_message("箱子是锁着的，需要解开机关")

func _on_button_pressed():
	if chest_opened:
		show_message("按钮按下了！出口门打开了！")
		$ExitDoor.tooltip_text = "出口门(已解锁)"
	else:
		show_message("按钮没有反应...")

func _on_hint_pressed():
	if Global.hints_remaining > 0 and current_hint_idx < hint_texts.size():
		show_message(hint_texts[current_hint_idx])
		current_hint_idx += 1
		Global.use_hint()
		hint_btn.text = "提示(" + str(Global.hints_remaining) + ")"

func _on_inventory_updated():
	if Global.has_item("torch"):
		dark_overlay.visible = false

func _on_exit_door_pressed():
	if chest_opened:
		show_message("你逃出了地下室！")
		await get_tree().create_timer(1.0).timeout
		complete_level()
	else:
		show_message("门是锁着的")
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
	get_tree().change_scene_to_file("res://src/scenes/" + Global.current_level + ".tscn")
