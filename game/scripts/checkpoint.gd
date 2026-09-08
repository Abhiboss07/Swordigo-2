extends Area3D

## Checkpoint Monument
## Restores player vitals, sets respawn point, and triggers persistent auto-save.

@export var checkpoint_id: String = "checkpoint_01"
var is_activated: bool = false

@onready var crystal_mesh: MeshInstance3D = $CrystalMesh
@onready var light: OmniLight3D = $OmniLight3D

func _ready() -> void:
	collision_layer = 64 # Layer 7: Interactable
	collision_mask = 2 # Layer 2: Player
	body_entered.connect(_on_body_entered)

	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.active_checkpoint_id == checkpoint_id:
		activate(false)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if not is_activated:
			activate(true)
		body.heal(body.max_health)
		body.restore_mana(body.max_mana)

func activate(play_effects: bool = true) -> void:
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

	var scene_path = get_tree().current_scene.scene_file_path if get_tree().current_scene else "res://scenes/original_campaign/cairnwood_forest_part1.tscn"
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.set_checkpoint(scene_path, global_position + Vector3(0.0, 0.5, 0.0), checkpoint_id)

	if play_effects:
		if has_node("/root/AudioManager"):
			get_node("/root/AudioManager").play_sfx("checkpoint")

		if gm and gm.player and gm.player.has_method("_spawn_floating_text"):
			gm.player._spawn_floating_text("CHECKPOINT REACHED", Color(0.0, 0.9, 1.0), 1.2)
