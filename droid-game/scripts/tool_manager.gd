extends Node

@export var slot_1: PackedScene
@export var slot_2: PackedScene
@export var slot_3: PackedScene

@onready var player = get_parent()
@onready var tool_mount: Node2D = player.get_node("ToolPivot/ToolMount")

var current_tool: Node
var current_slot: int = -1


func _ready() -> void:
	equip_slot(0)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("tool_slot_1"):
		equip_slot(0)

	elif Input.is_action_just_pressed("tool_slot_2"):
		equip_slot(1)

	elif Input.is_action_just_pressed("tool_slot_3"):
		equip_slot(2)


	if Input.is_action_just_pressed("use_tool"):
		if current_tool != null and current_tool.has_method("use_start"):
			current_tool.use_start()
		elif current_tool != null and current_tool.has_method("use"):
			current_tool.use()


	if Input.is_action_pressed("use_tool"):
		if current_tool != null and current_tool.has_method("use_hold"):
			current_tool.use_hold(delta)


	if Input.is_action_just_released("use_tool"):
		if current_tool != null and current_tool.has_method("use_stop"):
			current_tool.use_stop()


func equip_slot(slot: int) -> void:
	if current_slot == slot:
		return

	var tool_scene: PackedScene

	match slot:
		0:
			tool_scene = slot_1
		1:
			tool_scene = slot_2
		2:
			tool_scene = slot_3
		_:
			return

	if tool_scene == null:
		return

	if current_tool != null:
		current_tool.queue_free()

	current_tool = tool_scene.instantiate()
	tool_mount.add_child(current_tool)

	print("Equipped slot: ", slot)
	print("Tool scene: ", current_tool.name)
	print("Tool position: ", current_tool.position)

	current_slot = slot
	
	
