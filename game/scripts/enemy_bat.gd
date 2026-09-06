extends "res://scripts/enemy_base.gd"

## CaveBat (Authentic Swordigo Flying Enemy)
## Aerial pursuit enemy with sine-wave hovering, dive-bomb swoop attacks, and retreat behavior.

enum State { HOVER, DIVE, RETREAT }

var current_state: State = State.HOVER
var home_y: float = 0.0
var hover_time: float = 0.0
var target_dive_pos: Vector3 = Vector3.ZERO
var state_timer: float = 0.0

@export var detect_range: float = 9.0
@export var dive_speed: float = 8.0
@export var retreat_speed: float = 5.5

func _ready() -> void:
	max_health = 25
	damage = 10
	move_speed = 2.8
	xp_reward = 20
	coin_reward = 8
	soul_shard_reward = 3
	home_y = global_position.y
	super._ready()

func _custom_physics_process(delta: float) -> void:
	var gm = get_node_or_null("/root/GameManager")
	var player = gm.player if (gm and is_instance_valid(gm.player)) else null
	var dist_to_player = 999.0
	if player:
		dist_to_player = global_position.distance_to(player.global_position)

	match current_state:
		State.HOVER:
			hover_time += delta * 3.5
			velocity.y = sin(hover_time) * 1.4
			velocity.x = facing_direction * move_speed

			state_timer += delta
			if state_timer >= 2.0:
				state_timer = 0.0
				update_facing(-facing_direction)

			if dist_to_player <= detect_range and player and player.global_position.y < global_position.y:
				current_state = State.DIVE
				target_dive_pos = player.global_position
				state_timer = 0.0

		State.DIVE:
			state_timer += delta
			var dir = (target_dive_pos - global_position).normalized()
			velocity.x = dir.x * dive_speed
			velocity.y = dir.y * dive_speed
			update_facing(dir.x)

			if global_position.y <= target_dive_pos.y + 0.2 or state_timer >= 1.2:
				current_state = State.RETREAT
				state_timer = 0.0

		State.RETREAT:
			state_timer += delta
			velocity.y = retreat_speed
			velocity.x = facing_direction * (retreat_speed * 0.4)

			if global_position.y >= home_y or state_timer >= 1.6:
				current_state = State.HOVER
				state_timer = 0.0

	move_and_slide()
