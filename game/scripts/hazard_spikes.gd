extends Area3D

## HazardSpikes
## Environmental hazard dealing direct damage and upward knockback to trespassing entities.

@export var damage: int = 15
@export var upward_knockback: float = 12.0

func _ready() -> void:
	collision_layer = 32 # Layer 6: Hazard
	collision_mask = 2 # Layer 2: Player
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and body.has_method("take_damage"):
		var knock = Vector3(0.0, upward_knockback, 0.0)
		body.take_damage(damage, "hazard", knock)
