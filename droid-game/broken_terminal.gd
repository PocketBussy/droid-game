extends Area2D

@export var max_integrity: float = 100.0

var integrity: float = 25.0


func repair(amount: float) -> void:
	integrity = min(integrity + amount, max_integrity)

	print("Terminal integrity: ", integrity)

	if integrity >= max_integrity:
		print("Terminal fully repaired!")
