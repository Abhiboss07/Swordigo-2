extends "res://scripts/enemy_base.gd"

## ForestBeetle (Authentic Swordigo Armored Crawler)
## Ground-based patrolling armored beetle. Turns at ledges and walls, deals contact damage.

@export var ledge_check: bool = true

@onready var ledge_ray: RayCast3D = $Visuals/LedgeRay
@onready var wall_ray: RayCast3D = $Visuals/WallRay

func _ready() -> void:
	max_health = 35
	damage = 12
	move_speed = 2.4
	xp_reward = 25
	coin_reward = 10
	soul_shard_reward = 2
	super._ready()

func _custom_physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	# Turn at ledges or walls
	if is_on_floor():
		if (ledge_ray and not ledge_ray.is_colliding()) or (wall_ray and wall_ray.is_colliding()):
			update_facing(-facing_direction)

	velocity.x = facing_direction * move_speed
	move_and_slide()
