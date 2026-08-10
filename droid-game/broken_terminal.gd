extends Area2D

@export var max_integrity: float = 100.0
@export var integrity: float = 25.0
@export var powered_light: PointLight2D

@onready var repair_bar: ProgressBar = $RepairBar
@onready var terminal_sprite: AnimatedSprite2D = $TerminalSprite
@onready var broken_sprite: AnimatedSprite2D = $TerminalSprite/BrokenSprite
@onready var repaired_sprite: AnimatedSprite2D = $TerminalSprite/RepairedSprite

var repaired: bool = false


func _ready() -> void:
	repair_bar.max_value = max_integrity
	repair_bar.value = integrity
	repair_bar.visible = false

	broken_sprite.visible = true
	repaired_sprite.visible = false

	broken_sprite.play("Sad")

	if powered_light:
		powered_light.enabled = false


func repair(amount: float) -> void:
	if repaired:
		return

	repair_bar.visible = true

	integrity = min(integrity + amount, max_integrity)
	repair_bar.value = integrity

	if integrity >= max_integrity:
		fully_repaired()


func fully_repaired() -> void:
	

	
	repaired = true

	repair_bar.visible = false

	broken_sprite.visible = false
	repaired_sprite.visible = true

	repaired_sprite.play("Happy")

	terminal_sprite.modulate = Color(0.0, 0.673, 0.399, 1.0)

	if powered_light:
		powered_light.enabled = true

	print("Object fully repaired!")

	if powered_light:
		powered_light.enabled = true
		print("Light enabled: ", powered_light.enabled)
	else:
		print("No powered light assigned")
