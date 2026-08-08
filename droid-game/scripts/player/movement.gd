extends Node2D

var player_stats = {"Speed": 100, "TurnSpeed": 130, "Deccel": 400}

var direction = Vector2.ZERO
var Rotation_Dir = 0
@onready var player = get_parent()

func _process(delta: float) -> void:
	if Input.is_action_pressed("Forward"):
		player.velocity += player.transform.y * player_stats["Deccel"] * delta
		%BodySprite.play("Move")
	elif Input.is_action_pressed("Backward"):
		player.velocity -= player.transform.y * player_stats["Deccel"] * delta
		%BodySprite.play("Move")
	else: 
		player.velocity = player.velocity.move_toward(Vector2.ZERO, player_stats["Deccel"] * delta) 
		%BodySprite.play("Idle")
		
	if player.velocity.length() > 5:
		if Input.is_action_pressed("Left"):
			Rotation_Dir = -1
		elif Input.is_action_pressed("Right"):
			Rotation_Dir = +1
		else: Rotation_Dir = 0 
		
		player.rotation += deg_to_rad(player_stats["TurnSpeed"] * Rotation_Dir * delta)
		player.velocity = player.velocity.limit_length(player_stats["Speed"])
		player.move_and_slide()
