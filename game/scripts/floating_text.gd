extends Node3D

@onready var label: Label3D = $Label3D

var velocity: Vector3 = Vector3(0.0, 2.5, 0.0)
var lifetime: float = 0.8
var timer: float = 0.0

func _ready() -> void:
	velocity.x = randf_range(-0.5, 0.5)

func setup(text: String, color: Color = Color.WHITE, scale_factor: float = 1.0) -> void:
	if not label:
		label = $Label3D
	label.text = text
	label.modulate = color
	scale = Vector3.ONE * scale_factor

func _process(delta: float) -> void:
	position += velocity * delta
	velocity.y -= 1.8 * delta
	timer += delta
	var alpha = clamp(1.0 - (timer / lifetime), 0.0, 1.0)
	label.modulate.a = alpha

	if timer >= lifetime:
		queue_free()
