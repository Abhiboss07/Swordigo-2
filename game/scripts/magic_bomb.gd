extends RigidBody3D

## MagicBomb Projectile
## Authentic Swordigo throwable explosive that bounces, detonates, breaks cracked walls, and blasts enemies.

@export var damage: int = 40
@export var fuse_time: float = 2.0
@export var explosion_radius: float = 4.0

var direction: float = 1.0
var timer: float = 0.0
var has_exploded: bool = false

var floating_text_scene = preload("res://scenes/original_campaign/floating_text.tscn")

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var spark_light: OmniLight3D = $SparkLight

func _ready() -> void:
	collision_layer = 8 # PlayerHitbox
	collision_mask = 1 | 4 # World, Enemies
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)

func setup(dir: float, dmg: int = 40) -> void:
	direction = 1.0 if dir >= 0.0 else -1.0
	damage = dmg
	linear_velocity = Vector3(direction * 9.0, 7.5, 0.0)
	angular_velocity = Vector3(0.0, 0.0, -direction * 8.0)

func _physics_process(delta: float) -> void:
	if has_exploded:
		return

	# Strict 2.5D constraint
	position.z = 0.0
	linear_velocity.z = 0.0

	timer += delta
	if spark_light:
		spark_light.light_energy = 2.0 + sin(timer * 25.0) * 1.5

	if timer >= fuse_time:
		explode()

func _on_body_entered(body: Node) -> void:
	if has_exploded:
		return
	if body.is_in_group("Enemies"):
		explode()

func explode() -> void:
	if has_exploded:
		return
	has_exploded = true
	freeze = true

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("spell_aoe")

	var cam = get_viewport().get_camera_3d()
	if cam and cam.get_parent().has_method("add_trauma"):
		cam.get_parent().add_trauma(0.5)

	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has_method("take_damage"):
			var dist = global_position.distance_to(enemy.global_position)
			if dist <= explosion_radius:
				var falloff = 1.0 - (dist / explosion_radius) * 0.5
				var actual_dmg = int(damage * falloff)
				var dir = (enemy.global_position - global_position).normalized()
				var knockback = Vector3(dir.x * 12.0, 6.0, 0.0)
				enemy.take_damage(actual_dmg, "magic_explosion", knockback)

	var interactables = get_tree().get_nodes_in_group("Interactable")
	for obj in interactables:
		if is_instance_valid(obj) and obj.has_method("take_damage") and global_position.distance_to(obj.global_position) <= explosion_radius:
			obj.take_damage(damage)

	if mesh:
		var mat = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = Color(1.0, 0.6, 0.1)
		mesh.set_surface_override_material(0, mat)
		var tween = create_tween()
		tween.tween_property(mesh, "scale", Vector3(3.5, 3.5, 3.5), 0.15)
		tween.tween_property(mesh, "scale", Vector3.ZERO, 0.1)
		tween.tween_callback(queue_free)
	else:
		queue_free()
