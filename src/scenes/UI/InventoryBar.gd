extends CanvasLayer

const SLOT_COUNT = 6
const SLOT_SIZE = 80

var slot_buttons: Array[Button] = []
var slot_items: Array[Item] = []
var selected_slot: int = -1
var combination_system: Node = null

@onready var grid = $Panel/Grid
@onready var item_label = $ItemLabel

func _ready():
	combination_system = get_node_or_null("/root/CombinationSystem")
	
	for i in range(SLOT_COUNT):
		var btn = grid.get_child(i)
		slot_buttons.append(btn)
		slot_items.append(null)
		btn.pressed.connect(_on_slot_pressed.bind(i))
		btn.mouse_entered.connect(_on_slot_hover.bind(i))
		btn.mouse_exited.connect(_on_slot_exit)
	
	Global.inventory_updated.connect(_on_inventory_updated)
	Global.item_selected.connect(_on_item_selected)
	
	refresh_all_slots()

func _on_inventory_updated():
	refresh_all_slots()

func _on_item_selected(item: Item):
	# Update visual selection state
	pass

func refresh_all_slots():
	for i in range(SLOT_COUNT):
		var btn = slot_buttons[i]
		var item: Item = null if i >= Global.inventory.size() else Global.inventory[i]
		slot_items[i] = item
		
		# Clear existing children (icon/label)
		for child in btn.get_children():
			if child is Label or child is ColorRect:
				child.queue_free()
		
		if item != null:
			# Add color indicator
			var color_rect = ColorRect.new()
			color_rect.color = item.color
			color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
			color_rect.color.a = 0.9
			btn.add_child(color_rect)
			
			# Add name label at bottom
			var label = Label.new()
			label.text = item.name
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			label.position = Vector2(0, SLOT_SIZE - 20)
			label.size = Vector2(SLOT_SIZE, 20)
			label.add_theme_font_size_override("font_size", 12)
			btn.add_child(label)
		else:
			btn.tooltip_text = ""

func _on_slot_pressed(slot_idx: int):
	if slot_idx >= Global.inventory.size():
		return
	
	var item = Global.inventory[slot_idx]
	
	if Global.selected_item != null and Global.selected_item != item:
		# Try to combine
		if combination_system and combination_system.can_combine(Global.selected_item, item):
			var result = combination_system.try_combine(Global.selected_item, item)
			if result:
				Global.remove_item(Global.selected_item)
				Global.remove_item(item)
				Global.add_item(result)
				Global.deselect_item()
				show_combine_effect(result)
				return
	
	if Global.selected_item == item:
		Global.deselect_item()
	else:
		Global.select_item(item)

func _on_slot_hover(slot_idx: int):
	if slot_idx < Global.inventory.size():
		var item = Global.inventory[slot_idx]
		item_label.text = item.name + ": " + item.description
		item_label.visible = true

func _on_slot_exit():
	item_label.visible = false

func show_combine_effect(result_item: Item):
	# Flash effect on the slot that received the new item
	pass
