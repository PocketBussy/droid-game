extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var move_speed: float = 40.0
@export var repath_distance: float = 8.0
@export var search_time: float = 3.0
@export var search_turn_speed: float = 1.5
@export var search_angle: float = 60.0
@export var idle_fov: float = 100.0
@export var alert_fov: float = 180.0
@export var show_vision_cone: bool = true
@export var vision_distance: float = 150.0
@export var cone_segments: int = 24

@onready var projectile_spawn: Marker2D = $ProjectileSpawn
@onready var attack_timer: Timer = $AttackTimer
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var line_of_sight: RayCast2D = $LineOfSight

var last_target_position := Vector2.ZERO
var last_known_position := Vector2.ZERO
var has_last_known_position := false
var search_timer: float = 0.0
var search_start_rotation: float
var search_direction: float = 1.0

enum State {
	IDLE,
	CHASE,
	ATTACK,
	SEARCH
}


var state: State = State.IDLE
var target: Node2D = null


#region New Code Region
func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			idle()

		State.CHASE:
			chase()

		State.ATTACK:
			attack()

		State.SEARCH:
			search(delta)

	move_and_slide()

	queue_redraw()
#endregion

#region New Code Region
func idle() -> void:
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("Idle")

	if target != null and can_see_target():
		last_known_position = target.global_position
		has_last_known_position = true
		state = State.CHASE



func chase() -> void:
	if target == null:
		state = State.IDLE
		return

	if can_see_target():
		last_known_position = target.global_position
		has_last_known_position = true

		if last_target_position.distance_to(target.global_position) > repath_distance:
			navigation_agent.target_position = target.global_position
			last_target_position = target.global_position

	elif has_last_known_position:
		navigation_agent.target_position = last_known_position

	else:
		velocity = Vector2.ZERO
		state = State.IDLE
		return

	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO

		if not can_see_target() and has_last_known_position:
			has_last_known_position = false
			search_start_rotation = rotation
			search_timer = search_time
			state = State.SEARCH

		return

	var next_position := navigation_agent.get_next_path_position()
	var direction := global_position.direction_to(next_position)

	# Tell the navigation agent where we'd LIKE to move.
	navigation_agent.velocity = direction * move_speed

	$AnimatedSprite2D.play("Move")
#endregion

func is_target_in_fov() -> bool:
	if target == null:
		return false

	var direction_to_target := global_position.direction_to(
		target.global_position
	)

	var forward_direction := Vector2.DOWN.rotated(rotation)

	var angle_to_target := rad_to_deg(
		abs(forward_direction.angle_to(direction_to_target))
	)

	var current_fov := idle_fov

	if state == State.CHASE or state == State.ATTACK:
		current_fov = alert_fov

	return angle_to_target <= current_fov / 2.0


func attack() -> void:
	velocity = Vector2.ZERO

	if target == null:
		state = State.IDLE
		attack_timer.stop()
		return

	if not can_see_target():
		state = State.CHASE
		attack_timer.stop()
		return

	var direction := global_position.direction_to(target.global_position)

	if direction != Vector2.ZERO:
		rotation = direction.angle() - deg_to_rad(90)

#region New Code Region
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body
		print("Player in awareness range")


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
#endregion

#region New Code Region
func _on_attack_timer_timeout() -> void:
	if state != State.ATTACK or target == null:
		return

	if not can_see_target():
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
#endregion

func can_see_target() -> bool:
	if target == null:
		return false

	if not is_target_in_fov():
		return false

	line_of_sight.target_position = line_of_sight.to_local(
		target.global_position
	)

	line_of_sight.force_raycast_update()

	if not line_of_sight.is_colliding():
		return false

	return line_of_sight.get_collider() == target
	
func search(delta: float) -> void:
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("Idle")

	if target != null and can_see_target():
		last_known_position = target.global_position
		has_last_known_position = true
		state = State.CHASE
		return

	rotation += search_turn_speed * search_direction * delta

	var angle_from_start := angle_difference(
		search_start_rotation,
		rotation
	)

	var max_angle := deg_to_rad(search_angle)

	if abs(angle_from_start) >= max_angle:
		search_direction *= -1.0

	search_timer -= delta

	if search_timer <= 0.0:
		state = State.IDLE

func _draw() -> void:
	if not show_vision_cone:
		return

	var current_fov: float = idle_fov

	if state == State.CHASE or state == State.ATTACK:
		current_fov = alert_fov

	var half_fov: float = deg_to_rad(current_fov / 2.0)

	var points := PackedVector2Array()
	points.append(Vector2.ZERO)

	var space_state := get_world_2d().direct_space_state

	for i in range(cone_segments + 1):
		var t: float = float(i) / float(cone_segments)
		var angle: float = lerp(-half_fov, half_fov, t)

		var local_direction: Vector2 = Vector2.DOWN.rotated(angle)
		var world_direction: Vector2 = local_direction.rotated(global_rotation)

		var ray_start: Vector2 = global_position
		var ray_end: Vector2 = ray_start + world_direction * vision_distance

		var query := PhysicsRayQueryParameters2D.create(
			ray_start,
			ray_end
		)

		# Set this to your WALL collision layer.
		query.collision_mask = 2

		# Don't let the ray hit the alien itself.
		query.exclude = [get_rid()]

		var result := space_state.intersect_ray(query)

		var world_point: Vector2

		if result:
			world_point = result["position"]
		else:
			world_point = ray_end

		points.append(to_local(world_point))

	draw_colored_polygon(
		points,
		Color(1.0, 0.9, 0.2, 0.18)
	)


func _on_navigation_agent_2d_velocity_computed(
	safe_velocity: Vector2
) -> void:
	velocity = safe_velocity

	if state == State.CHASE or state == State.ATTACK:
		if target != null:
			var look_direction := global_position.direction_to(
				target.global_position
			)

			if look_direction != Vector2.ZERO:
				rotation = look_direction.angle() - deg_to_rad(90)

	elif velocity.length() > 0.1:
		rotation = velocity.angle() - deg_to_rad(90)
