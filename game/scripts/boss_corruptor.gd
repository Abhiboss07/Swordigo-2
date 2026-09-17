extends "res://scripts/enemy_base.gd"
class_name BossCorruptor

## The Corruptor Boss Controller (Authentic Swordigo First Major Boss)
## Dark shadow fiend that struck down the Master in Cairnwood.
## Features dark energy bolts, shockwave slams, shadow teleportation, and drops Mageblade Shard 1.

enum Phase { PHASE_1_ASSAULT, PHASE_2_SUMMON, PHASE_3_ENRAGE }

var current_phase: Phase = Phase.PHASE_1_ASSAULT
var boss_timer: float = 0.0
var attack_cooldown: float = 2.5
var is_acting: bool = false
var minion_instance: Node = null

@export var boss_name: String = "The Corruptor"
@export var dark_bolt_damage: int = 18
@export var slam_damage: int = 25
@export var minion_scene: PackedScene = preload("res://scenes/original_campaign/enemy_bat.tscn")

@onready var slam_hitbox: Area3D = $Visuals/SlamHitbox
@onready var eye_glow: OmniLight3D = $Visuals/EyeGlow
@onready var dark_aura: OmniLight3D = $Visuals/DarkAura

func _ready() -> void:
	max_health = 300
	damage = 20
	move_speed = 3.6
	xp_reward = 400
	coin_reward = 200
	soul_shard_reward = 50
	super._ready()

	current_health = max_health
	if slam_hitbox:
		slam_hitbox.monitoring = false
		slam_hitbox.collision_layer = 16
		slam_hitbox.collision_mask = 2

	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.boss_engaged.emit(boss_name, max_health)
		gm.boss_health_updated.emit(current_health, max_health)

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("boss_roar")

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
		var dir = sign(player.global_position.x - global_position.x)
		if not is_acting and dir != 0.0:
			update_facing(dir)

	var hp_ratio = float(current_health) / float(max_health)
	if hp_ratio > 0.66:
		current_phase = Phase.PHASE_1_ASSAULT
	elif hp_ratio > 0.33:
		current_phase = Phase.PHASE_2_SUMMON
	else:
		current_phase = Phase.PHASE_3_ENRAGE

	_process_boss_logic(delta, dist_to_player, player)
	move_and_slide()

func _process_boss_logic(delta: float, dist_to_player: float, player: Node = null) -> void:
	boss_timer += delta

	match current_phase:
		Phase.PHASE_1_ASSAULT:
			if not is_acting:
				velocity.x = facing_direction * move_speed
				if boss_timer >= attack_cooldown or dist_to_player <= 2.8:
					boss_timer = 0.0
					_execute_slam(1.0)
		Phase.PHASE_2_SUMMON:
			if not is_acting:
				velocity.x = facing_direction * (move_speed * 1.1)
				if minion_instance == null and minion_scene and is_inside_tree():
					minion_instance = minion_scene.instantiate()
					minion_instance.global_position = global_position + Vector3(facing_direction * 2.5, 3.0, 0.0)
					get_parent().add_child(minion_instance)
					if has_node("/root/AudioManager"):
						get_node("/root/AudioManager").play_sfx("portal")

				if boss_timer >= 3.0:
					boss_timer = 0.0
					if randf() > 0.5:
						_execute_shadow_teleport(player)
					else:
						_execute_slam(1.2)
		Phase.PHASE_3_ENRAGE:
			if dark_aura:
				dark_aura.light_color = Color(1.0, 0.1, 0.2)
				dark_aura.light_energy = 4.0
			if not is_acting:
				velocity.x = facing_direction * (move_speed * 1.6)
				if boss_timer >= 1.8:
					boss_timer = 0.0
					if randf() > 0.4:
						_execute_shadow_teleport(player)
					else:
						_execute_slam(1.5)

func _execute_slam(power: float) -> void:
	is_acting = true
	velocity.x = 0.0
	velocity.y = 9.0

	await get_tree().create_timer(0.45).timeout

	velocity.y = -20.0
	await get_tree().create_timer(0.25).timeout

	if slam_hitbox:
		slam_hitbox.monitoring = true

	var cam = get_viewport().get_camera_3d()
	if cam and cam.get_parent().has_method("add_trauma"):
		cam.get_parent().add_trauma(0.6 * power)

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("spell_aoe")
		get_node("/root/AudioManager").play_sfx("hit")

	await get_tree().create_timer(0.25).timeout

	if slam_hitbox:
		slam_hitbox.monitoring = false
	is_acting = false

func _execute_shadow_teleport(player: Node = null) -> void:
	is_acting = true
	velocity = Vector3.ZERO

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("portal")

	if visuals:
		var tween = create_tween()
		tween.tween_property(visuals, "scale", Vector3(0.1, 2.0, 0.1), 0.2)

	await get_tree().create_timer(0.3).timeout

	if player and is_instance_valid(player):
		var side = 1.0 if randf() > 0.5 else -1.0
		global_position.x = player.global_position.x + (side * 3.5)
		global_position.y = player.global_position.y + 0.5
		position.z = 0.0

	if visuals:
		var tween2 = create_tween()
		tween2.tween_property(visuals, "scale", Vector3.ONE, 0.2)

	await get_tree().create_timer(0.25).timeout
	is_acting = false

func take_damage(amount: int, damage_type: String = "physical", knockback: Vector3 = Vector3.ZERO) -> void:
	var dampened = knockback * 0.1
	super.take_damage(amount, damage_type, dampened)
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.boss_health_updated.emit(current_health, max_health)

func die() -> void:
	if is_dead:
		return

	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.boss_defeated.emit(boss_name)

	# Grant Mageblade Shard 1
	var inv = get_node_or_null("/root/Inventory")
	if inv:
		inv.add_item("iselon_shard_1")

	# Complete quests & set flag
	var qm = get_node_or_null("/root/QuestManager")
	if qm:
		qm.complete_quest("quest10_death")
		qm.set_flag("corruptor_defeated", true)
		qm.set_flag("boss_corruptor_defeated", true)
		qm.start_quest("quest_reforge_mageblade")

	if is_instance_valid(minion_instance):
		minion_instance.queue_free()

	var cam = get_viewport().get_camera_3d()
	if cam and cam.get_parent().has_method("add_trauma"):
		cam.get_parent().add_trauma(0.85)

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("victory")

	super.die()
