extends Area3D

## DimensionRift Spell
## Authentic Swordigo spell that tears open the dimensional veil, revealing ethereal platforms and damaging shadow entities.

@export var duration: float = 6.0
@export var damage_per_second: int = 15

var timer: float = 0.0

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var light: OmniLight3D = $OmniLight3D

func _ready() -> void:
	collision_layer = 8 # PlayerHitbox
	collision_mask = 4 # EnemyHurtbox
	_set_dimension_objects_visible(true)
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("portal")

func _physics_process(delta: float) -> void:
	var player = GameManager.player if (GameManager and is_instance_valid(GameManager.player)) else null
	if player:
		global_position = player.global_position + Vector3(0.0, 0.8, 0.0)

	position.z = 0.0 # Strict 2.5D anchor
	rotation.z += 1.5 * delta

	timer += delta
	if timer >= duration:
		_close_rift()

func _set_dimension_objects_visible(is_active: bool) -> void:
	var dim_objs = get_tree().get_nodes_in_group("DimensionObjects")
	for obj in dim_objs:
		if is_instance_valid(obj):
			if obj is VisualInstance3D:
				obj.visible = is_active
			if obj is CollisionObject3D:
				for child in obj.get_children():
					if child is CollisionShape3D:
						child.disabled = !is_active

func _close_rift() -> void:
	_set_dimension_objects_visible(false)
	queue_free()

func _exit_tree() -> void:
	_set_dimension_objects_visible(false)
