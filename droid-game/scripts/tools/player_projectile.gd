extends Area2D

@export var speed: float = 250.0
@export var damage: float = 25.0
@export var lifetime: float = 2.0

var direction := Vector2.ZERO


func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func setup(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
	rotation = direction.angle()


func _on_body_entered(body: Node2D) -> void:
	var health = body.get_node_or_null("Health")

	if health != null and health.has_method("take_damage"):
		health.take_damage(damage)

	queue_free()
