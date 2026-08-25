extends Camera3D

## CameraFollow25D
## Authentic Swordigo 2.5D camera tracking with smooth lerp, look-ahead, and vertical damping.

@export var target_path: NodePath
@export var smooth_speed: float = 6.0
@export var offset: Vector3 = Vector3(0, 1.8, 9.5)
@export var look_ahead_distance: float = 1.5
@export var min_limit_y: float = -10.0

var target: Node3D = null

func _ready() -> void:
	if has_node(target_path):
		target = get_node(target_path)
	elif has_node("/root/GameManager"):
		var gm = get_node("/root/GameManager")
		if gm.player:
			target = gm.player

func _physics_process(delta: float) -> void:
	if not target or not is_instance_valid(target):
		var players = get_tree().get_nodes_in_group("Player")
		if not players.is_empty():
			target = players[0]
		else:
			return

	var facing = 1.0
	if "facing_direction" in target:
		facing = float(target.facing_direction)

	var target_pos = target.global_position
	var desired_x = target_pos.x + (facing * look_ahead_distance)
	var desired_y = max(target_pos.y + offset.y, min_limit_y)
	var desired_z = offset.z

	var desired_pos = Vector3(desired_x, desired_y, desired_z)
	global_position = global_position.lerp(desired_pos, smooth_speed * delta)
	look_at(Vector3(global_position.x, desired_y - 0.5, 0.0), Vector3.UP)
