extends Area3D

## Breakable Clay Pot
## Shatters on melee or magical impact; drops coins, health, or soul shards.

@export var reward_coins: int = 6
@export var reward_health: int = 15
@export var drops_health: bool = true

var is_broken: bool = false

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	collision_layer = 4 # Layer 3: EnemyHurtbox (receives PlayerHitbox)
	collision_mask = 8 # Layer 4: PlayerHitbox

func take_damage(_amount: int, _damage_type: String = "physical", _knockback: Vector3 = Vector3.ZERO) -> void:
	if is_broken:
		return
	shatter()

func shatter() -> void:
	is_broken = true
	collision_shape.set_deferred("disabled", true)

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("pot_break")

	var inv = get_node_or_null("/root/Inventory")
	if inv:
		inv.add_coins(reward_coins)

	var gm = get_node_or_null("/root/GameManager")
	if drops_health and gm and gm.player and is_instance_valid(gm.player):
		gm.player.heal(reward_health)

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.3, 0.2, 1.3), 0.1)
	tween.tween_property(self, "scale", Vector3.ZERO, 0.1)
	tween.tween_callback(queue_free)
