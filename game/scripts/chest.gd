extends Area3D

## Treasure Chest
## Interactive chest rewarding coins, equipment, or key items; supports mimic surprise ambushes.

@export var chest_id: String = "chest_01"
@export var reward_coins: int = 40
@export var reward_item_id: String = ""
@export var is_mimic: bool = false

var is_opened: bool = false
var player_in_range: bool = false

@onready var lid_pivot: Node3D = $LidPivot
@onready var prompt_label: Label3D = $PromptLabel

func _ready() -> void:
	collision_layer = 64 # Layer 7: Interactable
	collision_mask = 2 # Layer 2: Player
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if prompt_label:
		prompt_label.visible = false

	var qm = get_node_or_null("/root/QuestManager")
	if qm and qm.get_flag("chest_opened_" + chest_id, false):
		_set_opened_visual()

func _process(_delta: float) -> void:
	if player_in_range and not is_opened:
		if Input.is_action_just_pressed("interact"):
			open_chest()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and not is_opened:
		player_in_range = true
		if prompt_label:
			prompt_label.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		if prompt_label:
			prompt_label.visible = false

func open_chest() -> void:
	if is_opened:
		return
	is_opened = true
	if prompt_label:
		prompt_label.visible = false

	if lid_pivot:
		var tween = create_tween()
		tween.tween_property(lid_pivot, "rotation:x", -1.45, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var qm = get_node_or_null("/root/QuestManager")
	if qm:
		qm.set_flag("chest_opened_" + chest_id, true)

	if is_mimic:
		_trigger_mimic()
		return

	var inv = get_node_or_null("/root/Inventory")
	if inv:
		if reward_coins > 0:
			inv.add_coins(reward_coins)
		if reward_item_id != "":
			inv.add_item(reward_item_id)

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("chest")

	var reward_text = "+%d Coins" % reward_coins
	if reward_item_id != "" and inv and inv.item_definitions.has(reward_item_id):
		var item_name = inv.item_definitions[reward_item_id]["name"]
		reward_text += "\nFound %s!" % item_name

	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.player and gm.player.has_method("_spawn_floating_text"):
		gm.player._spawn_floating_text(reward_text, Color(0.98, 0.79, 0.28), 1.2)

func _trigger_mimic() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("boss_roar")
	var mimic_scene = load("res://scenes/original_campaign/enemy_skeleton.tscn")
	if mimic_scene:
		var mimic = mimic_scene.instantiate()
		mimic.global_position = global_position + Vector3(0.0, 0.5, 0.0)
		get_parent().add_child(mimic)
	queue_free()

func _set_opened_visual() -> void:
	is_opened = true
	if lid_pivot:
		lid_pivot.rotation.x = -1.45
