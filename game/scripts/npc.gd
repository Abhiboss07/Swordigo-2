extends Area3D

## NPC Character
## Interactive character providing dialogue, lore, and quest advancement.

@export var npc_name: String = "The Master"
@export var dialogue_lines: Array[String] = [
	"Ah, you have arrived, my apprentice.",
	"A great corruption has begun spreading through Cairnwood Forest.",
	"Open the chest behind me to claim your Brass Sword, then make your way to the Village!"
]
@export var starts_quest_id: String = "quest01_find_master"
@export var completes_quest_id: String = ""

var player_in_range: bool = false

@onready var prompt_label: Label3D = $PromptLabel

func _ready() -> void:
	collision_layer = 64 # Layer 7: Interactable
	collision_mask = 2 # Layer 2: Player
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label:
		prompt_label.visible = false

func _process(_delta: float) -> void:
	if player_in_range:
		if Input.is_action_just_pressed("interact"):
			start_dialogue()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		if prompt_label:
			prompt_label.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		if prompt_label:
			prompt_label.visible = false

func start_dialogue() -> void:
	var db = get_tree().current_scene.find_child("DialogueBox", true, false)
	if db and db.has_method("display_dialogue"):
		db.display_dialogue(npc_name, dialogue_lines)

	var qm = get_node_or_null("/root/QuestManager")
	if qm:
		if starts_quest_id != "":
			qm.start_quest(starts_quest_id)
		if completes_quest_id != "":
			qm.complete_quest(completes_quest_id)
