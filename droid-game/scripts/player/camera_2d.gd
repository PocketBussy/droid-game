extends Camera2D

@export var player: Node2D
@export var follow_weight: float = 0.04

func _process(_delta: float) -> void:
	if not player:
		return
	
	var mouse_pos =  get_global_mouse_position()
	
	var target_pos = player.global_position + (mouse_pos - player.global_position) * 0.1

	global_position = global_position.lerp(target_pos, follow_weight)
