extends StaticBody2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var powered: bool = false


func power_on() -> void:
	if powered:
		return

	powered = true

	print("Door received power!")

	animation_player.play("open")

	await animation_player.animation_finished

	collision.set_deferred("disabled", true)

	print("Door opened!")
