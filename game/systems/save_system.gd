extends Node

## SaveSystem Singleton
## Manages JSON save serialization, profile slots, and checkpoint auto-saving.
## Supports separate tracking for Classic Campaign and Sequel Expansion.

signal save_completed(slot_index: int)
signal load_completed(slot_index: int)
signal save_error(message: String)

const SAVE_DIR = "user://saves/"
var active_slot: int = 1
var current_slot: int:
	get:
		return active_slot
	set(val):
		active_slot = val

func get_slot_info(slot_index: int) -> Dictionary:
	var path = get_save_path(slot_index)
	if not FileAccess.file_exists(path):
		return {"exists": false}
	var meta = get_slot_metadata(slot_index)
	meta["exists"] = true
	return meta

func new_game(slot_index: int = 1) -> void:
	active_slot = slot_index
	var inv = get_node_or_null("/root/Inventory")
	var qm = get_node_or_null("/root/QuestManager")
	var gm = get_node_or_null("/root/GameManager")
	if inv and inv.has_method("reset"):
		inv.reset()
	if qm and qm.has_method("reset"):
		qm.reset()
	if gm and gm.has_method("reset_session"):
		gm.reset_session()
	save_game(slot_index)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_save_dir()

func _ensure_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func get_save_path(slot_index: int) -> String:
	return SAVE_DIR + "save_slot_%d.json" % slot_index

func has_save(slot_index: int) -> bool:
	return FileAccess.file_exists(get_save_path(slot_index))

func get_slot_metadata(slot_index: int) -> Dictionary:
	var path = get_save_path(slot_index)
	if not FileAccess.file_exists(path):
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}

	var json_str = file.get_as_text()
	var parsed = JSON.parse_string(json_str)
	if parsed is Dictionary:
		return {
			"profile_name": parsed.get("profile_name", "Hero"),
			"campaign_mode": parsed.get("campaign_mode", 0),
			"level": parsed.get("level", 1),
			"playtime_seconds": parsed.get("playtime_seconds", 0.0),
			"current_zone": parsed.get("current_zone", "Cairnwood Forest"),
			"timestamp": parsed.get("timestamp", "")
		}
	return {}

func auto_save() -> bool:
	return save_game(active_slot)

func save_game(slot_index: int = 1) -> bool:
	_ensure_save_dir()
	active_slot = slot_index
	var path = get_save_path(slot_index)

	var inv = get_node_or_null("/root/Inventory")
	var qm = get_node_or_null("/root/QuestManager")
	var gm = get_node_or_null("/root/GameManager")

	var save_data = {
		"profile_name": "Hero",
		"timestamp": Time.get_datetime_string_from_system(),
		"campaign_mode": gm.current_campaign_mode if gm else 0,
		"playtime_seconds": gm.playtime_seconds if gm else 0.0,
		"current_zone": gm.current_zone_path if gm else "res://scenes/original_campaign/cairnwood_forest_part1.tscn",
		"checkpoint_zone": gm.active_checkpoint_zone if gm else "res://scenes/original_campaign/cairnwood_forest_part1.tscn",
		"checkpoint_pos": [gm.active_checkpoint_pos.x, gm.active_checkpoint_pos.y, gm.active_checkpoint_pos.z] if gm else [0, 1.5, 0],
		"checkpoint_id": gm.active_checkpoint_id if gm else "default",
		# Economy & Level
		"level": inv.level if inv else 1,
		"xp": inv.xp if inv else 0,
		"xp_to_next": inv.xp_to_next if inv else 100,
		"coins": inv.coins if inv else 0,
		"soul_shards": inv.soul_shards if inv else 0,
		# Base Stats
		"base_max_health": inv.base_max_health if inv else 100,
		"base_max_mana": inv.base_max_mana if inv else 50,
		"base_attack": inv.base_attack if inv else 10,
		"base_defense": inv.base_defense if inv else 2,
		"base_magic": inv.base_magic if inv else 10,
		# Equipment
		"equipped_weapon": inv.equipped_weapon if inv else "brass_sword",
		"equipped_armor": inv.equipped_armor if inv else "cloth_tunic",
		"equipped_amulet": inv.equipped_amulet if inv else "",
		"equipped_ring_1": inv.equipped_ring_1 if inv else "",
		"equipped_ring_2": inv.equipped_ring_2 if inv else "",
		"equipped_trinket": inv.equipped_trinket if inv else "",
		# Spells
		"unlocked_spells": inv.unlocked_spells if inv else ["magic_bolt"],
		"active_spell_index": inv.active_spell_index if inv else 0,
		# Items & Shards
		"items": inv.items if inv else [],
		"key_items": inv.key_items if inv else [],
		# Story & Quests
		"story_flags": qm.story_flags if qm else {},
		"active_quests": qm.active_quests if qm else {},
		"completed_quests": qm.completed_quests if qm else []
	}

	var json_str = JSON.stringify(save_data, "\t")
	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		save_error.emit("Failed to open file for writing: " + path)
		return false

	file.store_string(json_str)
	file.close()
	save_completed.emit(slot_index)
	return true

func load_game(slot_index: int = 1) -> bool:
	active_slot = slot_index
	var path = get_save_path(slot_index)
	if not FileAccess.file_exists(path):
		save_error.emit("Save file does not exist: " + path)
		return false

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		save_error.emit("Failed to open file for reading: " + path)
		return false

	var json_str = file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_str)
	if not (data is Dictionary):
		save_error.emit("Corrupted save file payload.")
		return false

	var inv = get_node_or_null("/root/Inventory")
	var qm = get_node_or_null("/root/QuestManager")
	var gm = get_node_or_null("/root/GameManager")

	if gm:
		gm.current_campaign_mode = data.get("campaign_mode", 0)
		gm.playtime_seconds = data.get("playtime_seconds", 0.0)
		gm.current_zone_path = data.get("current_zone", "res://scenes/original_campaign/cairnwood_forest_part1.tscn")
		gm.active_checkpoint_zone = data.get("checkpoint_zone", gm.current_zone_path)
		var cpos = data.get("checkpoint_pos", [0, 1.5, 0])
		if cpos is Array and cpos.size() >= 3:
			gm.active_checkpoint_pos = Vector3(cpos[0], cpos[1], cpos[2])
		gm.active_checkpoint_id = data.get("checkpoint_id", "default")

	if inv:
		inv.level = data.get("level", 1)
		inv.xp = data.get("xp", 0)
		inv.xp_to_next = data.get("xp_to_next", 100)
		inv.coins = data.get("coins", 0)
		inv.soul_shards = data.get("soul_shards", 0)
		inv.base_max_health = data.get("base_max_health", 100)
		inv.base_max_mana = data.get("base_max_mana", 50)
		inv.base_attack = data.get("base_attack", 10)
		inv.base_defense = data.get("base_defense", 2)
		inv.base_magic = data.get("base_magic", 10)
		inv.equipped_weapon = data.get("equipped_weapon", "brass_sword")
		inv.equipped_armor = data.get("equipped_armor", "cloth_tunic")
		inv.equipped_amulet = data.get("equipped_amulet", "")
		inv.equipped_ring_1 = data.get("equipped_ring_1", "")
		inv.equipped_ring_2 = data.get("equipped_ring_2", "")
		inv.equipped_trinket = data.get("equipped_trinket", "")

		var spells = data.get("unlocked_spells", ["magic_bolt"])
		inv.unlocked_spells.clear()
		for s in spells:
			inv.unlocked_spells.append(str(s))
		inv.active_spell_index = data.get("active_spell_index", 0)

		var raw_items = data.get("items", [])
		inv.items.clear()
		for itm in raw_items:
			if itm is Dictionary:
				inv.items.append(itm)

		var raw_keys = data.get("key_items", [])
		inv.key_items.clear()
		for k in raw_keys:
			inv.key_items.append(str(k))

	if qm:
		qm.story_flags = data.get("story_flags", {})
		qm.active_quests = data.get("active_quests", {})
		var raw_completed = data.get("completed_quests", [])
		qm.completed_quests.clear()
		for cq in raw_completed:
			qm.completed_quests.append(str(cq))

	load_completed.emit(slot_index)
	return true

func delete_save(slot_index: int) -> bool:
	var path = get_save_path(slot_index)
	if FileAccess.file_exists(path):
		var err = DirAccess.remove_absolute(path)
		return err == OK
	return false
