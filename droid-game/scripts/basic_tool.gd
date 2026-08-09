extends Node2D

@export var tool_name: String = "Basic Tool"

@onready var muzzle: Marker2D = $Muzzle

func use() -> void:
	print("Using", tool_name)
	
