extends Node2D

@export var tool_name: String = "Repair Welder"
@export var repair_amount: float = 25.0
@export var cooldown: float = 0.5

@onready var repair_area: Area2D = $RepairArea
#@onready var animation_player: AnimationPlayer = $AnimationPlayer

var can_repair := true


func use() -> void:
	if not can_repair:
		return

	can_repair = false

	#animation_player.play("repair")
	$AnimatedSprite2D.play("Weld")
	for area in repair_area.get_overlapping_areas():
		if area.has_method("repair"):
			area.repair(repair_amount)
			break

	await get_tree().create_timer(cooldown).timeout
	can_repair = true
