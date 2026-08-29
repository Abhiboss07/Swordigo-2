extends Area3D

## MagicBolt Projectile
## High-velocity magical energy bolt that damages enemies and triggers distance switches.

@export var speed: float = 18.0
@export var damage: int = 20
@export var lifetime: float = 2.0

var direction: float = 1.0
var timer: float = 0.0

func _ready() -> void:
	collision_layer = 8 # Layer 4: PlayerHitbox
	collision_mask = 1 | 4 | 64 # Layer 1 (World), Layer 3 (EnemyHurtbox), Layer 7 (Interactable)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func setup(dir: float, dmg: int) -> void:
	direction = 1.0 if dir >= 0.0 else -1.0
	damage = dmg
	rotation.y = 0.0 if direction > 0.0 else PI

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta
	position.z = 0.0 # Strict 2.5D constraint
	timer += delta
	if timer >= lifetime:
		queue_free()

func _on_body_entered(_body: Node3D) -> void:
	_create_impact_vfx()
	queue_free()

func _on_area_entered(area: Area3D) -> void:
	var parent_entity = area.get_parent()
	if parent_entity and parent_entity.has_method("take_damage"):
		var knockback = Vector3(direction * 8.0, 3.0, 0.0)
		parent_entity.take_damage(damage, "magic", knockback)
		if has_node("/root/AudioManager"):
			get_node("/root/AudioManager").play_sfx("hit")

	if parent_entity and parent_entity.has_method("trigger_switch"):
		parent_entity.trigger_switch()

	_create_impact_vfx()
	queue_free()

func _create_impact_vfx() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("magic")
