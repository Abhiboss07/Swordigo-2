extends "res://scripts/enemy_base.gd"
class_name BossVoidWeaver

## BossVoidWeaver (Additive Sequel Expansion Final Boss)
## Built strictly reusing the authentic Caver engine ECS architecture and asset pipeline.
## Features cosmic web threads, void teleportation, ethereal summon waves, and ground nova slams.

enum Phase { WEAVE, SUMMON, ASTRAL_FRENZY }

var current_phase: Phase = Phase.WEAVE
var boss_timer: float = 0.0
var attack_cooldown: float = 2.2
var is_acting: bool = false

@export var boss_name: String = "The Void Weaver"
@export var web_bolt_damage: int = 24
@export var nova_damage: int = 35

@onready var nova_hitbox: Area3D = $Visuals/NovaHitbox
@onready var astral_core_light: OmniLight3D = $Visuals/AstralCoreLight

func _ready() -> void:
	max_health = 450
	damage = 25
	move_speed = 3.8
	xp_reward = 800
	coin_reward = 350
	soul_shard_reward = 80
	super._ready()

	current_health = max_health
	if nova_hitbox:
		nova_hitbox.monitoring = false
		nova_hitbox.collision_layer = 16
		nova_hitbox.collision_mask = 2

	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.boss_engaged.emit(boss_name, max_health)
		gm.boss_health_changed.emit(boss_name, current_health, max_health)

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("boss_roar")

func _custom_physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var gm = get_node_or_null("/root/GameManager")
	var player = gm.player if (gm and is_instance_valid(gm.player)) else null
	if not player:
		return

	var dist = player.global_position.x - global_position.x
	update_facing(sign(dist))

	boss_timer += delta
	if boss_timer >= attack_cooldown and not is_acting:
		boss_timer = 0.0
		_choose_attack(dist)

func _choose_attack(dist: float) -> void:
	is_acting = true
	var hp_ratio = float(current_health) / float(max_health)
	if hp_ratio > 0.65:
		current_phase = Phase.WEAVE
		_cast_web_bolt()
	elif hp_ratio > 0.3:
		current_phase = Phase.SUMMON
		if randf() > 0.5:
			_teleport_and_slam()
		else:
			_cast_web_bolt()
	else:
		current_phase = Phase.ASTRAL_FRENZY
		_teleport_and_slam()

func _cast_web_bolt() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("magic")

	var gm = get_node_or_null("/root/GameManager")
	var player = gm.player if (gm and is_instance_valid(gm.player)) else null
	if player:
		var dir = (player.global_position - global_position).normalized()
		player.take_damage(web_bolt_damage, "magic", dir * 6.0)

	var tween = create_tween()
	tween.tween_property(visuals, "scale", Vector3(1.3, 1.3, 1.3), 0.15)
	tween.tween_property(visuals, "scale", Vector3.ONE, 0.2)
	await tween.finished
	is_acting = false

func _teleport_and_slam() -> void:
	var gm = get_node_or_null("/root/GameManager")
	var player = gm.player if (gm and is_instance_valid(gm.player)) else null
	if not player:
		is_acting = false
		return

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("portal")

	var fade = create_tween()
	fade.tween_property(visuals, "modulate:a", 0.0, 0.2)
	await fade.finished

	global_position.x = player.global_position.x + (-facing_direction * 2.5)
	global_position.y = player.global_position.y + 4.0

	var show_tween = create_tween()
	show_tween.tween_property(visuals, "modulate:a", 1.0, 0.1)
	await show_tween.finished

	velocity.y = -18.0
	while not is_on_floor():
		await get_tree().physics_frame

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("spell_aoe")

	if nova_hitbox:
		nova_hitbox.monitoring = true
		await get_tree().create_timer(0.12).timeout
		nova_hitbox.monitoring = false

	is_acting = false

func take_damage(amount: int, damage_type: String = "physical", knockback: Vector3 = Vector3.ZERO) -> void:
	super.take_damage(amount, damage_type, knockback * 0.2)
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.boss_health_changed.emit(boss_name, current_health, max_health)

func die() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.boss_defeated.emit(boss_name)
	super.die()
