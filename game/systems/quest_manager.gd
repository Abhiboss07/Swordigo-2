extends Node

## QuestManager Singleton (Authentic Swordigo Narrative Architecture)
## Manages story flags, quest progression, and chapter milestones.

signal quest_started(quest_id: String, title: String)
signal quest_stage_advanced(quest_id: String, stage: int, objective: String)
signal quest_completed(quest_id: String, reward_coins: int)
signal flag_changed(flag_name: String, value: Variant)

var story_flags: Dictionary = {}
var active_quests: Dictionary = {} # quest_id -> current_stage
var completed_quests: Array[String] = []

var quest_definitions: Dictionary = {
	# Authentic Swordigo Questline
	"quest01_find_master": {
		"title": "The Master's Call",
		"description": "Seek your Master in Cairnwood Forest.",
		"reward_coins": 40,
		"stages": [
			{"stage": 0, "objective": "Head east into Cairnwood Forest."},
			{"stage": 1, "objective": "Find the Master at the corrupted clearing."}
		]
	},
	"quest10_death": {
		"title": "The Corruptor's Shadow",
		"description": "Survive the ambush by the dark fiend that struck down your Master.",
		"reward_coins": 80,
		"stages": [
			{"stage": 0, "objective": "Survive the Corruptor's assault."},
			{"stage": 1, "objective": "Escape to Cairnwood Village."}
		]
	},
	"quest_reforge_mageblade": {
		"title": "The Mageblade Reforged",
		"description": "Recover the four Iselon Shards to reforge the legendary blade and banish the Lord of Chaos.",
		"reward_coins": 500,
		"stages": [
			{"stage": 0, "objective": "Recover the first Mageblade Shard from the Corruptor's Crypt."},
			{"stage": 1, "objective": "Bring the shard to Elder Vorn in Cairnwood Village."}
		]
	}
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func set_flag(flag_name: String, value: Variant) -> void:
	story_flags[flag_name] = value
	flag_changed.emit(flag_name, value)

func get_flag(flag_name: String, default_value: Variant = false) -> Variant:
	return story_flags.get(flag_name, default_value)

func start_quest(quest_id: String) -> bool:
	if not quest_definitions.has(quest_id) or completed_quests.has(quest_id):
		return false
	if not active_quests.has(quest_id):
		active_quests[quest_id] = 0
		var title = quest_definitions[quest_id]["title"]
		quest_started.emit(quest_id, title)
		return true
	return false

func advance_quest(quest_id: String) -> void:
	if not active_quests.has(quest_id):
		return
	var current_stage = active_quests[quest_id]
	var stages = quest_definitions[quest_id]["stages"]
	if current_stage + 1 < stages.size():
		active_quests[quest_id] = current_stage + 1
		quest_stage_advanced.emit(quest_id, active_quests[quest_id], stages[active_quests[quest_id]]["objective"])
	else:
		complete_quest(quest_id)

func complete_quest(quest_id: String) -> void:
	if not active_quests.has(quest_id):
		return
	active_quests.erase(quest_id)
	if not completed_quests.has(quest_id):
		completed_quests.append(quest_id)
	var reward = quest_definitions[quest_id].get("reward_coins", 0)
	if reward > 0 and has_node("/root/Inventory"):
		get_node("/root/Inventory").add_coins(reward)
	quest_completed.emit(quest_id, reward)

func is_quest_active(quest_id: String) -> bool:
	return active_quests.has(quest_id)

func is_quest_completed(quest_id: String) -> bool:
	return completed_quests.has(quest_id)

func get_quest_stage(quest_id: String) -> int:
	return active_quests.get(quest_id, -1)

func reset() -> void:
	reset_to_defaults()

func reset_to_defaults() -> void:
	story_flags.clear()
	active_quests.clear()
	completed_quests.clear()
