extends Area3D

## CrystalSwitch
## Hit-activated arcane crystal switch. Can be triggered by melee attacks or Magic Bolt to open doors.

signal activated(switch_id: String)

@export var switch_id: String = "switch_01"
@export var target_gate_path: NodePath
@export var is_reusable: bool = false

var is_activated: bool = false

@onready var crystal_mesh: MeshInstance3D = $CrystalMesh
@onready var light: OmniLight3D = $OmniLight3D

func _ready() -> void:
	collision_layer = 4 | 64 # Layer 3: EnemyHurtbox + Layer 7: Interactable
	collision_mask = 8      # Layer 4: PlayerHitbox

func take_damage(_amount: int, _damage_type: String = "physical", _knockback: Vector3 = Vector3.ZERO) -> void:
	trigger_switch()

func trigger_switch() -> void:
	if is_activated and not is_reusable:
		return

	is_activated = true

	if crystal_mesh:
		var mat = crystal_mesh.get_surface_override_material(0)
		if not mat:
			mat = StandardMaterial3D.new()
			crystal_mesh.set_surface_override_material(0, mat)
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = Color(0.0, 0.9, 1.0)

	if light:
		light.light_color = Color(0.0, 0.9, 1.0)
		light.light_energy = 3.0

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("switch")

	activated.emit(switch_id)

	if target_gate_path:
		var gate = get_node_or_null(target_gate_path)
		if gate and gate.has_method("open_gate"):
			gate.open_gate()
		elif gate is Node3D:
			var tween = create_tween()
			tween.tween_property(gate, "position:y", gate.position.y + 4.0, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
