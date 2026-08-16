extends Node

signal health_changed(current_health: float)
signal died

@export var max_health: float = 100.0

var health: float


func _ready() -> void:
	health = max_health


func take_damage(amount: float) -> void:
	if health <= 0.0:
		return

	health = max(health - amount, 0.0)

	print(get_parent().name, " health: ", health)

	health_changed.emit(health)

	if health <= 0.0:
		died.emit()
