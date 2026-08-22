extends CharacterBody3D
class_name Player

## Player Controller (Authentic 2.5D Swordigo Kinematic Model)
## Reconstructs the exact arcade physics, 3-hit sword combo, spell library, and stat scaling.

signal health_updated(current: int, maximum: int)
signal mana_updated(current: int, maximum: int)
signal died

# Physics constants (Caver-Calibrated)
@export var max_speed: float = 8.0
@export var acceleration: float = 60.0
@export var deceleration: float = 50.0
@export var jump_velocity: float = 13.5
@export var double_jump_velocity: float = 12.5
@export var gravity_up: float = 32.0
@export var gravity_down: float = 38.0
@export var wall_slide_speed: float = 3.0
@export var wall_jump_velocity: Vector2 = Vector2(7.5, 11.5)

# Timers & windows
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
const COYOTE_DURATION: float = 0.12
const JUMP_BUFFER_DURATION: float = 0.15

# State flags
var can_double_jump: bool = false
var is_wall_sliding: bool = false
var wall_normal: Vector3 = Vector3.ZERO
var facing_direction: float = 1.0 # +1 right, -1 left

# Combat state
var is_attacking: bool = false
var combo_stage: int = 0
var combo_timer: float = 0.0
var attack_duration: float = 0.28
var attack_cooldown: float = 0.0

# Magic state
var cast_cooldown: float = 0.0
var magic_bolt_scene = preload("res://scenes/original_campaign/magic_bolt.tscn")
var magic_bomb_scene = preload("res://scenes/original_campaign/magic_bomb.tscn")
var dimension_rift_scene = preload("res://scenes/original_campaign/dimension_rift.tscn")
var floating_text_scene = preload("res://scenes/original_campaign/floating_text.tscn")

# Health, Mana, and Invulnerability
var current_health: int = 100
var max_health: int = 100
var current_mana: int = 50
var max_mana: int = 50
var mana_regen_rate: float = 3.0 # per second
var mana_regen_accumulator: float = 0.0

var is_invulnerable: bool = false
var invulnerability_timer: float = 0.0
var invulnerability_duration: float = 1.0
var is_dead: bool = false

# Node references
@onready var visuals: Node3D = $Visuals
@onready var weapon_hitbox: Area3D = $Visuals/WeaponHitbox
@onready var sword_pivot: Node3D = $Visuals/SwordPivot
@onready var hurtbox: Area3D = $Hurtbox
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	add_to_group("Player")
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("register_player"):
		gm.register_player(self)
	sync_stats_from_inventory()
	current_health = max_health
	current_mana = max_mana
	emit_health_and_mana()

	if weapon_hitbox:
		weapon_hitbox.monitoring = false
		weapon_hitbox.area_entered.connect(_on_weapon_hitbox_area_entered)

	if hurtbox:
		hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func sync_stats_from_inventory() -> void:
	var inv = get_node_or_null("/root/Inventory")
	if inv:
		max_health = inv.get_total_max_health()
		max_mana = inv.get_total_max_mana()
		current_health = min(current_health, max_health)
		current_mana = min(current_mana, max_mana)
		emit_health_and_mana()

func emit_health_and_mana() -> void:
	health_updated.emit(current_health, max_health)
	mana_updated.emit(current_mana, max_mana)
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.player_health_changed.emit(current_health, max_health)
		gm.player_mana_changed.emit(current_mana, max_mana)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Always clamp Z to 0.0 (Strict 2.5D constraint)
	position.z = 0.0
	velocity.z = 0.0

	_handle_timers(delta)
	_handle_mana_regen(delta)
	_handle_combat_timers(delta)
	_handle_horizontal_movement(delta)
	_handle_jumping_and_gravity(delta)
	_handle_combat_inputs()

	move_and_slide()

	_check_wall_contact()
	_update_visuals(delta)

func _handle_timers(delta: float) -> void:
	if is_on_floor():
		coyote_timer = COYOTE_DURATION
		can_double_jump = true
	else:
		coyote_timer = max(0.0, coyote_timer - delta)

	if jump_buffer_timer > 0.0:
		jump_buffer_timer = max(0.0, jump_buffer_timer - delta)

	if is_invulnerable:
		invulnerability_timer -= delta
		if invulnerability_timer <= 0.0:
			is_invulnerable = false
			if visuals:
				visuals.visible = true
		else:
			if visuals:
				visuals.visible = fmod(invulnerability_timer, 0.1) > 0.05

func _handle_mana_regen(delta: float) -> void:
	if current_mana < max_mana:
		mana_regen_accumulator += mana_regen_rate * delta
		if mana_regen_accumulator >= 1.0:
			var gain = int(mana_regen_accumulator)
			current_mana = min(max_mana, current_mana + gain)
			mana_regen_accumulator -= gain
			emit_health_and_mana()

func _handle_combat_timers(delta: float) -> void:
	if attack_cooldown > 0.0:
		attack_cooldown = max(0.0, attack_cooldown - delta)

	if cast_cooldown > 0.0:
		cast_cooldown = max(0.0, cast_cooldown - delta)

	if is_attacking:
		combo_timer -= delta
		if combo_timer <= 0.0:
			_end_attack()

func _handle_horizontal_movement(delta: float) -> void:
	var input_x = Input.get_axis("move_left", "move_right")
	var speed_multiplier = 0.35 if is_attacking else 1.0

	if input_x != 0.0:
		facing_direction = sign(input_x)
		var target_vel = input_x * max_speed * speed_multiplier
		velocity.x = move_toward(velocity.x, target_vel, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)

func _handle_jumping_and_gravity(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_DURATION

	if jump_buffer_timer > 0.0:
		if is_wall_sliding and not is_on_floor():
			jump_buffer_timer = 0.0
			velocity.y = wall_jump_velocity.y
			velocity.x = wall_normal.x * wall_jump_velocity.x
			facing_direction = sign(velocity.x)
			is_wall_sliding = false
			if has_node("/root/AudioManager"):
				get_node("/root/AudioManager").play_sfx("jump")
		elif coyote_timer > 0.0:
			jump_buffer_timer = 0.0
			coyote_timer = 0.0
			velocity.y = jump_velocity
			if has_node("/root/AudioManager"):
				get_node("/root/AudioManager").play_sfx("jump")
		elif can_double_jump:
			jump_buffer_timer = 0.0
			can_double_jump = false
			velocity.y = double_jump_velocity
			if has_node("/root/AudioManager"):
				get_node("/root/AudioManager").play_sfx("double_jump")

	if Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y *= 0.5

	if not is_on_floor():
		if is_wall_sliding and velocity.y < 0.0:
			velocity.y = move_toward(velocity.y, -wall_slide_speed, gravity_down * delta * 0.5)
		else:
			var grav = gravity_up if velocity.y > 0.0 else gravity_down
			velocity.y -= grav * delta

func _check_wall_contact() -> void:
	if is_on_wall_only() and velocity.y < 0.0:
		var norm = get_wall_normal()
		var input_x = Input.get_axis("move_left", "move_right")
		if (norm.x > 0.0 and input_x < 0.0) or (norm.x < 0.0 and input_x > 0.0):
			is_wall_sliding = true
			wall_normal = norm
			can_double_jump = true
			return
	is_wall_sliding = false

func _handle_combat_inputs() -> void:
	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0.0:
		_start_attack()

	if Input.is_action_just_pressed("spell") and cast_cooldown <= 0.0:
		_cast_spell()

	if Input.is_action_just_pressed("spell_cycle"):
		var inv = get_node_or_null("/root/Inventory")
		if inv:
			inv.cycle_spell()
			if has_node("/root/AudioManager"):
				get_node("/root/AudioManager").play_sfx("switch")

func _start_attack() -> void:
	is_attacking = true
	combo_stage = (combo_stage % 3) + 1
	combo_timer = attack_duration
	attack_cooldown = attack_duration + 0.05

	if weapon_hitbox:
		weapon_hitbox.monitoring = true

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("attack", 0.08)

	if sword_pivot:
		var target_angle = -1.6 if combo_stage == 1 else (1.6 if combo_stage == 2 else -2.2)
		var tween = create_tween()
		tween.tween_property(sword_pivot, "rotation:z", target_angle, attack_duration * 0.4)
		tween.tween_property(sword_pivot, "rotation:z", 0.0, attack_duration * 0.6)

func _end_attack() -> void:
	is_attacking = false
	if weapon_hitbox:
		weapon_hitbox.monitoring = false
	if sword_pivot:
		sword_pivot.rotation.z = 0.0

func _cast_spell() -> void:
	var inv = get_node_or_null("/root/Inventory")
	var active_spell = inv.get_active_spell() if inv else "magic_bolt"

	match active_spell:
		"magic_bolt":
			var cost = 12
			if current_mana >= cost:
				current_mana -= cost
				cast_cooldown = 0.35
				emit_health_and_mana()
				_spawn_magic_bolt()
		"magic_bomb":
			var cost = 20
			if current_mana >= cost:
				current_mana -= cost
				cast_cooldown = 0.7
				emit_health_and_mana()
				_spawn_magic_bomb()
		"dimension_rift":
			var cost = 30
			if current_mana >= cost:
				current_mana -= cost
				cast_cooldown = 2.0
				emit_health_and_mana()
				_spawn_dimension_rift()

func _spawn_magic_bolt() -> void:
	var bolt = magic_bolt_scene.instantiate()
	var spawn_pos = global_position + Vector3(facing_direction * 0.8, 0.4, 0.0)
	bolt.global_position = spawn_pos
	var inv = get_node_or_null("/root/Inventory")
	var magic_dmg = 15 + int(inv.get_total_magic() * 1.2) if inv else 20
	bolt.setup(facing_direction, magic_dmg)
	get_parent().add_child(bolt)

func _spawn_magic_bomb() -> void:
	var bomb = magic_bomb_scene.instantiate()
	var spawn_pos = global_position + Vector3(facing_direction * 0.7, 0.8, 0.0)
	bomb.global_position = spawn_pos
	var inv = get_node_or_null("/root/Inventory")
	var magic_dmg = 35 + int(inv.get_total_magic() * 1.5) if inv else 40
	bomb.setup(facing_direction, magic_dmg)
	get_parent().add_child(bomb)

func _spawn_dimension_rift() -> void:
	var rift = dimension_rift_scene.instantiate()
	rift.global_position = global_position + Vector3(0.0, 0.8, 0.0)
	get_parent().add_child(rift)

func _on_weapon_hitbox_area_entered(area: Area3D) -> void:
	var target_entity = area.get_parent()
	if target_entity and target_entity.has_method("take_damage"):
		var inv = get_node_or_null("/root/Inventory")
		var base_atk = inv.get_total_attack() if inv else 15
		var multiplier = 1.0 if combo_stage == 1 else (1.2 if combo_stage == 2 else 1.8)
		var dmg = int(base_atk * multiplier)
		var knock_strength = 7.0 if combo_stage < 3 else 12.0
		var knockback = Vector3(facing_direction * knock_strength, 4.0, 0.0)

		target_entity.take_damage(dmg, "physical", knockback)
		if has_node("/root/AudioManager"):
			get_node("/root/AudioManager").play_sfx("hit")

		_apply_hitstop(0.04)

func _apply_hitstop(duration: float) -> void:
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

func _on_hurtbox_area_entered(area: Area3D) -> void:
	if is_invulnerable or is_dead:
		return

	var enemy = area.get_parent()
	var dmg = 10
	var knock_dir = -facing_direction

	if enemy:
		if "damage" in enemy:
			dmg = enemy.damage
		knock_dir = sign(global_position.x - enemy.global_position.x)
		if knock_dir == 0.0:
			knock_dir = -facing_direction

	take_damage(dmg, "enemy_contact", Vector3(knock_dir * 7.0, 4.5, 0.0))

func take_damage(raw_amount: int, damage_type: String = "physical", knockback: Vector3 = Vector3.ZERO) -> void:
	if is_invulnerable or is_dead:
		return

	var inv = get_node_or_null("/root/Inventory")
	var defense = inv.get_total_defense() if inv else 2
	var final_damage = max(1, raw_amount - defense)
	current_health = max(0, current_health - final_damage)

	emit_health_and_mana()
	_spawn_floating_text(str(final_damage), Color(1.0, 0.25, 0.25))

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("hurt")

	var cam = get_viewport().get_camera_3d()
	if cam and cam.get_parent().has_method("add_trauma"):
		cam.get_parent().add_trauma(0.35)

	if current_health <= 0:
		die()
	else:
		is_invulnerable = true
		invulnerability_timer = invulnerability_duration
		velocity = knockback

func heal(amount: int) -> void:
	if is_dead:
		return
	current_health = min(max_health, current_health + amount)
	emit_health_and_mana()
	_spawn_floating_text("+" + str(amount), Color(0.2, 1.0, 0.3))

func restore_mana(amount: int) -> void:
	current_mana = min(max_mana, current_mana + amount)
	emit_health_and_mana()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector3.ZERO
	died.emit()
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("trigger_game_over"):
		gm.trigger_game_over()
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("hurt")

func _spawn_floating_text(text: String, color: Color, scale_factor: float = 1.0) -> void:
	if not is_inside_tree() or not get_parent():
		return
	var ft = floating_text_scene.instantiate()
	get_parent().add_child(ft)
	ft.global_position = global_position + Vector3(0.0, 1.2, 0.0)
	ft.setup(text, color, scale_factor)

func on_level_up() -> void:
	sync_stats_from_inventory()
	current_health = max_health
	current_mana = max_mana
	emit_health_and_mana()
	_spawn_floating_text("LEVEL UP!", Color(1.0, 0.85, 0.0), 1.4)
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("victory")

func _update_visuals(delta: float) -> void:
	if visuals:
		var target_rot_y = 0.0 if facing_direction > 0.0 else PI
		visuals.rotation.y = lerp_angle(visuals.rotation.y, target_rot_y, 16.0 * delta)
