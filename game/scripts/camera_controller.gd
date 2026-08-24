extends Node3D

## CameraController (2.5D Caver-Calibrated)
## Smooth follow camera with lookahead, vertical deadzone, room clamping, and trauma-based screenshake.

@export var smooth_speed: float = 6.0
@export var lookahead_distance: float = 2.0
@export var vertical_offset: float = 1.2
@export var fixed_z_distance: float = 8.5

# Room bounds clamping
@export var limit_left: float = -50.0
@export var limit_right: float = 150.0
@export var limit_bottom: float = -20.0
@export var limit_top: float = 40.0

@onready var camera: Camera3D = $Camera3D

var target: Node3D = null
var current_lookahead: float = 0.0
var trauma: float = 0.0
var trauma_decay: float = 1.8
var max_shake_offset: float = 0.6
var max_shake_angle: float = 0.06

func _ready() -> void:
	if camera:
		camera.position.z = fixed_z_distance
	find_player()

func find_player() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.player and is_instance_valid(gm.player):
		target = gm.player
	else:
		target = get_tree().get_first_node_in_group("Player")

func add_trauma(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)

func set_bounds(left: float, right: float, bottom: float, top: float) -> void:
	limit_left = left
	limit_right = right
	limit_bottom = bottom
	limit_top = top

func _physics_process(delta: float) -> void:
	if not target or not is_instance_valid(target):
		find_player()
		if not target:
			return

	var target_facing: float = 0.0
	if target is CharacterBody3D:
		var cb = target as CharacterBody3D
		if abs(cb.velocity.x) > 0.5:
			target_facing = sign(cb.velocity.x)
	current_lookahead = lerp(current_lookahead, target_facing * lookahead_distance, 4.0 * delta)

	var target_x = target.global_position.x + current_lookahead
	var target_y = target.global_position.y + vertical_offset

	target_x = clamp(target_x, limit_left, limit_right)
	target_y = clamp(target_y, limit_bottom, limit_top)

	global_position.x = lerp(global_position.x, target_x, smooth_speed * delta)
	global_position.y = lerp(global_position.y, target_y, smooth_speed * delta)
	global_position.z = 0.0

	if trauma > 0.0:
		trauma = max(0.0, trauma - trauma_decay * delta)
		var shake = trauma * trauma
		if camera:
			camera.h_offset = randf_range(-1.0, 1.0) * max_shake_offset * shake
			camera.v_offset = randf_range(-1.0, 1.0) * max_shake_offset * shake
			camera.rotation.z = randf_range(-1.0, 1.0) * max_shake_angle * shake
	else:
		if camera:
			camera.h_offset = 0.0
			camera.v_offset = 0.0
			camera.rotation.z = 0.0
