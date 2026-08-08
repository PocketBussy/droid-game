extends Area2D

@onready var scan_highlight: Sprite2D = $ScanHighlight


func on_scan() -> void:
	scan_highlight.visible = true

	await get_tree().create_timer(1.5).timeout

	scan_highlight.visible = false
	
	scan_highlight.modulate = Color(0.2, 1.0, 0.2)
