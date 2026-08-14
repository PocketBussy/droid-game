extends CharacterBody2D

@export var projectile_scene: PackedScene

@onready var projectile_spawn: Marker2D = $ProjectileSpawn
@onready var attack_timer: Timer = $AttackTimer

enum State {
	IDLE,
	CHASE,
	ATTACK
}

@export var move_speed: float = 40.0

var state: State = State.IDLE
var target: Node2D = null


func _physics_process(_delta: float) -> void:
	match state:
		State.IDLE:
			idle()

		State.CHASE:
			chase()

		State.ATTACK:
			attack()

	move_and_slide()


func idle() -> void:
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("Idle")

func chase() -> void:
	if target == null:
		state = State.IDLE
		return

	var direction := global_position.direction_to(target.global_position)

	velocity = direction * move_speed
	rotation = direction.angle() - deg_to_rad(90)
	$AnimatedSprite2D.play("Move")

func attack() -> void:
	velocity = Vector2.ZERO

	if target == null:
		state = State.IDLE
		return

	var direction := global_position.direction_to(target.global_position)
	rotation = direction.angle() - deg_to_rad(90)

func _on_detection_area_body_entered(body: Node2D) -> void:
	print("Something entered: ", body.name)

	if body.is_in_group("player"):
		print("Player detected!")
		target = body
		state = State.CHASE


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		state = State.IDLE
		print("Player lost!")
		

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body
		state = State.ATTACK
		attack_timer.start()

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body == target:
		state = State.CHASE
		attack_timer.stop()
		
func _on_attack_timer_timeout() -> void:
	if state != State.ATTACK or target == null:
		return

	fire_projectile()


func fire_projectile() -> void:
	if projectile_scene == null:
		return

	var projectile = projectile_scene.instantiate()

	get_tree().current_scene.add_child(projectile)

	projectile.global_position = projectile_spawn.global_position

	var direction := projectile_spawn.global_position.direction_to(
		target.global_position
	)

	projectile.setup(direction)

	print("Alien fired!")
	$AnimatedSprite2D.play("Attack")
