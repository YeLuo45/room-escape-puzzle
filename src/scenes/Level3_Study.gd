extends Node2D

var diary_found: bool = false
var diary_opened: bool = false
var diary_unlocked: bool = false
var coin_found: bool = false
var correct_password: String = "0618"

@onready var diary_panel = $Diary
@onready var diary_open_panel = $DiaryOpen
@onready var coin_panel = $Coin
@onready var password_input = $PasswordInput
@onready var hint_btn = $HintBtn
@onready var message_label = $MessageLabel

var hint_texts = [
	"书桌上好像有什么东西...",
	"日记密码提示：生日日期（06月18日）",
	"密码是0618，输入后拿走硬币"
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

func _on_desk_pressed():
	if not diary_found:
		diary_found = true
		diary_panel.visible = true
		show_message("你在书桌上发现了一本密码日记！")
	else:
		show_message("书桌上只有日记本了")

func _on_shelf_pressed():
	if not coin_found and diary_unlocked:
		coin_found = true
		coin_panel.visible = true
		show_message("书架后面藏着一枚硬币！")
	else:
		show_message("这是一个普通的书架")

func _on_diary_pressed():
	diary_opened = true
	diary_open_panel.visible = true
	password_input.text = ""

func _on_close_diary_pressed():
	diary_open_panel.visible = false
	diary_opened = false

func _on_unlock_pressed():
	var entered = password_input.text.strip_edges()
	if entered == correct_password:
		diary_unlocked = true
		diary_open_panel.visible = false
		show_message("日记解锁成功！里面提到书架后面藏着什么...")
	else:
		show_message("密码错误！")
		var tween = create_tween()
		var orig = password_input.position
		for i in range(3):
			tween.tween_property(password_input, "position:x", orig.x + 10, 0.05)
			tween.tween_property(password_input, "position:x", orig.x - 10, 0.05)
		tween.tween_property(password_input, "position:x", orig.x, 0.05)

func _on_coin_pressed():
	coin_panel.visible = false
	var coin_item = load("res://src/resources/items/coin.tres")
	Global.add_item(coin_item)
	show_message("获得：硬币")

func _on_hint_pressed():
	if Global.hints_remaining > 0 and current_hint_idx < hint_texts.size():
		show_message(hint_texts[current_hint_idx])
		current_hint_idx += 1
		Global.use_hint()
		hint_btn.text = "提示(" + str(Global.hints_remaining) + ")"

func _on_inventory_updated():
	pass

func _on_exit_door_pressed():
	if Global.has_item("coin"):
		show_message("硬币投入门锁，门开了！")
		await get_tree().create_timer(1.0).timeout
		complete_level()
	else:
		show_message("门锁需要硬币才能打开")
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
