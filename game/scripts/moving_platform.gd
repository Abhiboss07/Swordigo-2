extends AnimatableBody3D

## MovingPlatform (2.5D)
## Smoothly interpolates back and forth between waypoints using physics synchronization.

@export var move_offset: Vector3 = Vector3(6.0, 0.0, 0.0)
@export var move_duration: float = 3.0
@export var wait_duration: float = 0.6

var start_pos: Vector3
var target_pos: Vector3
var time_accumulator: float = 0.0
var moving_to_target: bool = true
var waiting: bool = false
var wait_timer: float = 0.0

func _ready() -> void:
	collision_layer = 1 # Layer 1: World
	collision_mask = 2  # Layer 2: Player
	start_pos = position
	target_pos = start_pos + move_offset
	start_pos.z = 0.0
	target_pos.z = 0.0

func _physics_process(delta: float) -> void:
	if waiting:
		wait_timer += delta
		if wait_timer >= wait_duration:
			waiting = false
			wait_timer = 0.0
			moving_to_target = !moving_to_target
		return

	time_accumulator += delta
	var t = clamp(time_accumulator / move_duration, 0.0, 1.0)
	var eased_t = (1.0 - cos(t * PI)) * 0.5

	if moving_to_target:
		position = start_pos.lerp(target_pos, eased_t)
	else:
		position = target_pos.lerp(start_pos, eased_t)

	if t >= 1.0:
		time_accumulator = 0.0
		waiting = true
