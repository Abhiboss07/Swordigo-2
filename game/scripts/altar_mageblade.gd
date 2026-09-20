extends Area3D

## AltarMageblade
## Sanctuary altar where all four Iselon Shards are reunited to reforge The Mageblade.

signal mageblade_reforged

var is_reforged: bool = false
var player_in_range: bool = false

@onready var prompt_label: Label3D = get_node_or_null("PromptLabel")
@onready var altar_glow: OmniLight3D = get_node_or_null("AltarGlow")
@onready var sword_visual: Node3D = get_node_or_null("SwordVisual")

func _ready() -> void:
	collision_layer = 64 # Layer 7: Interactable
	collision_mask = 2 # Layer 2: Player
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label:
		prompt_label.visible = false

func _process(_delta: float) -> void:
	if player_in_range and not is_reforged:
		if Input.is_action_just_pressed("interact"):
			reforge_mageblade()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and not is_reforged:
		player_in_range = true
		if prompt_label:
			prompt_label.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		if prompt_label:
			prompt_label.visible = false

func reforge_mageblade() -> void:
	var inv = get_node_or_null("/root/Inventory")
	var gm = get_node_or_null("/root/GameManager")
	var player = gm.player if (gm and is_instance_valid(gm.player)) else null

	if not inv or not inv.is_mageblade_complete():
		if player and player.has_method("_spawn_floating_text"):
			player._spawn_floating_text("Requires all 4 Mageblade Shards!", Color(1.0, 0.4, 0.4), 1.2)
		return

	is_reforged = true
	if prompt_label:
		prompt_label.visible = false

	inv.equip_weapon("the_mageblade")

	if player and player.has_method("_spawn_floating_text"):
		player._spawn_floating_text("THE MAGEBLADE REFORGED!", Color(0.2, 0.9, 1.0), 1.6)

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("victory")

	if altar_glow:
		altar_glow.light_energy = 5.0
		altar_glow.light_color = Color(0.2, 0.9, 1.0)

	mageblade_reforged.emit()
