extends Node2D

@export var repair_speed: float = 30.0

@onready var repair_area: Area2D = $RepairArea
@onready var sparks: GPUParticles2D = $Sparks


var welding: bool = false


func use_start() -> void:
	welding = true
	print("Welder started")

func use_hold(delta: float) -> void:
	if not welding:
		return

	var repairing_target := false

	for area in repair_area.get_overlapping_areas():
		if area.has_method("repair"):
			area.repair(repair_speed * delta)
			$AnimatedSprite2D.play("Weld")
			repairing_target = true
			break
	sparks.emitting = repairing_target

func use_stop() -> void:
	welding = false
	print("Welder stopped")
	$AnimatedSprite2D.play("Idle")
	sparks.emitting = false
