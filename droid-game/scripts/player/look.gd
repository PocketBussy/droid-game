extends Node2D
@export var head_speed: float = 8.0
@export var tool_speed: float = 14.0
@export var aim_offset: float = -90
@onready var player: CharacterBody2D = get_parent()
@onready var head_pivot = player.get_node("HeadPivot")
@onready var tool_pivot = player.get_node("ToolPivot")


func _physics_process(delta):
	
	aim_at_mouse(head_pivot, head_speed, delta)
	aim_at_mouse(tool_pivot, tool_speed, delta)

	
func aim_at_mouse(pivot: Node2D, speed: float, delta: float):
	var mouse_position = player.get_global_mouse_position() 
	var direction = mouse_position - pivot.global_position
	
	var target_rotation = direction.angle() + deg_to_rad(aim_offset)
	
	pivot.global_rotation = lerp_angle(
	pivot.global_rotation,
	target_rotation,
	speed * delta)
	
