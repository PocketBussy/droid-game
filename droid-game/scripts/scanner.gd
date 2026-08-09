extends Node2D

@export var scan_radius: float = 5.0
@export var pulse_base_radius: float = 23.0
@export var scan_duration: float = 0.6
@export var cooldown: float = 2.0

@onready var scan_pulse: AnimatedSprite2D = $ScanPulse
@onready var animation_player: AnimationPlayer = $ScanPulse/AnimationPlayer
#@onready var scan_shape: CircleShape2D = \
#	$ScanArea/CollisionShape2D.shape as CircleShape2D

var can_scan := true


func _ready() -> void:
	var shape := $ScanArea/CollisionShape2D.shape as CircleShape2D
	shape.radius = scan_radius

func use() -> void:
	if not can_scan:
		return

	can_scan = false

	scan_pulse.play("Scan")
	animation_player.play("scanfade")

	perform_scan()

	await get_tree().create_timer(cooldown).timeout
	can_scan = true

func perform_scan() -> void:
	for area in $ScanArea.get_overlapping_areas():
		if area.has_method("on_scan"):
			area.on_scan()
