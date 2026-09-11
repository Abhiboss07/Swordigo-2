extends Area3D

## Portal
## Seamless zone transition trigger connecting levels via named spawn markers.

@export var target_scene_path: String = "res://scenes/original_campaign/cairnwood_village.tscn"
@export var target_spawn_name: String = "Spawn_From_Forest"
@export var requires_key: String = ""
@export var locked_message: String = "Locked. Requires an ancient key."

var is_transitioning: bool = false

@onready var portal_glow: OmniLight3D = $PortalGlow

func _ready() -> void:
	collision_layer = 64 # Layer 7: Interactable
	collision_mask = 2 # Layer 2: Player
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if is_transitioning:
		return

	if body.is_in_group("Player"):
		if requires_key != "":
			var inv = get_node_or_null("/root/Inventory")
			if inv and not inv.has_item(requires_key):
				if body.has_method("_spawn_floating_text"):
					body._spawn_floating_text(locked_message, Color(1.0, 0.4, 0.4))
				if has_node("/root/AudioManager"):
					get_node("/root/AudioManager").play_sfx("hurt")
				return

		is_transitioning = true
		if has_node("/root/AudioManager"):
			get_node("/root/AudioManager").play_sfx("portal")

		if has_node("/root/SceneTransition"):
			get_node("/root/SceneTransition").transition_to_scene(target_scene_path, target_spawn_name)
		else:
			get_tree().change_scene_to_file(target_scene_path)
