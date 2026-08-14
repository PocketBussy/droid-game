extends Node2D

@export var projectile_scene: PackedScene
@export var fire_cooldown: float = 0.35

@onready var muzzle: Marker2D = $Muzzle

var can_fire := true


func use() -> void:
	if not can_fire:
		return

	if projectile_scene == null:
		return

	can_fire = false

	fire_projectile()

	await get_tree().create_timer(fire_cooldown).timeout
	can_fire = true


func fire_projectile() -> void:
	var projectile = projectile_scene.instantiate()

	get_tree().current_scene.add_child(projectile)

	projectile.global_position = muzzle.global_position
	projectile.global_rotation = muzzle.global_rotation

	var direction := Vector2.RIGHT.rotated(muzzle.global_rotation)

	projectile.setup(direction)
