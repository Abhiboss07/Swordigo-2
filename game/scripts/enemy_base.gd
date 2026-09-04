extends CharacterBody3D
class_name EnemyBase

## EnemyBase (Authentic Swordigo Entity Base)
## Provides health tracking, poise, floating combat numbers, and drop management.

signal health_changed(current: int, maximum: int)
signal enemy_died(enemy: EnemyBase)

@export var max_health: int = 40
@export var damage: int = 12
@export var move_speed: float = 3.5
@export var xp_reward: int = 25
@export var coin_reward: int = 8
@export var soul_shard_reward: int = 2

var current_health: int = 40
var is_invulnerable: bool = false
var invulnerable_timer: float = 0.0
var is_dead: bool = false

var gravity: float = 28.0
var facing_direction: float = -1.0

var floating_text_scene = preload("res://scenes/original_campaign/floating_text.tscn")

@onready var visuals: Node3D = get_node_or_null("Visuals")
@onready var hurtbox: Area3D = get_node_or_null("Hurtbox")
@onready var attack_hitbox: Area3D = get_node_or_null("Visuals/AttackHitbox")

func _ready() -> void:
	add_to_group("Enemies")
	current_health = max_health
	if hurtbox:
		hurtbox.collision_layer = 4 # Layer 3: EnemyHurtbox
		hurtbox.collision_mask = 8  # Layer 4: PlayerHitbox

	if attack_hitbox:
		attack_hitbox.collision_layer = 16 # Layer 5: EnemyHitbox
		attack_hitbox.collision_mask = 2   # Layer 2: PlayerHurtbox

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Strict 2.5D constraint
	position.z = 0.0
	velocity.z = 0.0

	if is_invulnerable:
		invulnerable_timer -= delta
		if invulnerable_timer <= 0.0:
			is_invulnerable = false
			if visuals:
				visuals.visible = true
		else:
			if visuals:
				visuals.visible = fmod(invulnerable_timer, 0.08) > 0.04

	_custom_physics_process(delta)

func _custom_physics_process(_delta: float) -> void:
	pass

func take_damage(amount: int, damage_type: String = "physical", knockback: Vector3 = Vector3.ZERO) -> void:
	if is_invulnerable or is_dead:
		return

	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)

	var text_color = Color(0.25, 0.88, 0.82) if damage_type == "magic" else (Color(1.0, 0.6, 0.1) if damage_type == "magic_explosion" else Color(1.0, 1.0, 1.0))
	_spawn_floating_text(str(amount), text_color)

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("hit")

	if current_health <= 0:
		die()
	else:
		is_invulnerable = true
		invulnerable_timer = 0.25
		velocity = knockback

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector3.ZERO
	enemy_died.emit(self)

	var inv = get_node_or_null("/root/Inventory")
	if inv:
		inv.add_xp(xp_reward)
		inv.add_coins(coin_reward)
		inv.add_soul_shards(soul_shard_reward)

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("coin")

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.22)
	tween.tween_callback(queue_free)

func _spawn_floating_text(text: String, color: Color) -> void:
	var ft = floating_text_scene.instantiate()
	ft.global_position = global_position + Vector3(0.0, 1.0, 0.0)
	ft.setup(text, color)
	get_parent().add_child(ft)

func update_facing(dir: float) -> void:
	if dir == 0.0:
		return
	facing_direction = sign(dir)
	if visuals:
		visuals.rotation.y = 0.0 if facing_direction > 0.0 else PI
