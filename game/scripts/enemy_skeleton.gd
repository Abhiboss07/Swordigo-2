extends "res://scripts/enemy_base.gd"

## CorruptSkeleton (Authentic Swordigo Undead Warrior)
## Wields an ancient sword and shield; blocks frontal attacks unless staggered or hit with Magic Bomb.

enum State { PATROL, CHASE, ATTACK, BLOCK }

var current_state: State = State.PATROL
var attack_timer: float = 0.0

@export var aggro_distance: float = 7.5
@export var attack_range: float = 1.4
@export var chase_speed: float = 4.2

@onready var ledge_ray: RayCast3D = $Visuals/LedgeRay
@onready var wall_ray: RayCast3D = $Visuals/WallRay
@onready var sword_pivot: Node3D = $Visuals/SwordPivot

func _ready() -> void:
	max_health = 50
	damage = 15
	move_speed = 2.6
	xp_reward = 40
	coin_reward = 16
	soul_shard_reward = 5
	super._ready()

func _custom_physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	var gm = get_node_or_null("/root/GameManager")
	var player = gm.player if (gm and is_instance_valid(gm.player)) else null
	var dist_to_player = 999.0
	if player:
		dist_to_player = global_position.distance_to(player.global_position)

	match current_state:
		State.PATROL:
			_process_patrol(delta, dist_to_player, player)
		State.CHASE:
			_process_chase(delta, dist_to_player, player)
		State.ATTACK:
			_process_attack(delta)

	move_and_slide()

func _process_patrol(delta: float, dist_to_player: float, player: Node3D) -> void:
	if dist_to_player < aggro_distance and abs(global_position.y - player.global_position.y) < 2.5:
		current_state = State.CHASE
		return

	if is_on_floor():
		if (ledge_ray and not ledge_ray.is_colliding()) or (wall_ray and wall_ray.is_colliding()):
			update_facing(-facing_direction)

	velocity.x = facing_direction * move_speed

func _process_chase(delta: float, dist_to_player: float, player: Node3D) -> void:
	if not player or dist_to_player > aggro_distance * 1.5:
		current_state = State.PATROL
		return

	var dir_to_player = sign(player.global_position.x - global_position.x)
	if dir_to_player != 0.0:
		update_facing(dir_to_player)

	if dist_to_player <= attack_range:
		current_state = State.ATTACK
		attack_timer = 0.65
		velocity.x = 0.0
		return

	if is_on_floor() and ledge_ray and not ledge_ray.is_colliding():
		velocity.x = 0.0
	else:
		velocity.x = facing_direction * chase_speed

func _process_attack(delta: float) -> void:
	velocity.x = 0.0
	attack_timer -= delta

	if attack_timer <= 0.35 and attack_timer > 0.15:
		if attack_hitbox:
			attack_hitbox.monitoring = true
		if sword_pivot:
			sword_pivot.rotation.z = -1.8
	else:
		if attack_hitbox:
			attack_hitbox.monitoring = false
		if sword_pivot:
			sword_pivot.rotation.z = 0.0

	if attack_timer <= 0.0:
		current_state = State.CHASE
