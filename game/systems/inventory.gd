extends Node

## Inventory & Equipment Singleton (Authentic Swordigo System)
## Manages player economy (Coins & Soul Shards), authentic weapon progression,
## bauble/trinket slots, and spell library.

signal coins_changed(new_amount: int)
signal soul_shards_changed(new_amount: int)
signal inventory_updated
signal equipment_changed(slot: String, item_id: String)
signal spell_changed(spell_id: String)
signal level_up(new_level: int)

var coins: int = 50
var soul_shards: int = 0
var level: int = 1
var xp: int = 0
var xp_to_next: int = 100
var unspent_stat_points: int = 0

# Base stats
var base_max_health: int = 100
var base_max_mana: int = 50
var base_attack: int = 10
var base_defense: int = 2
var base_magic: int = 10

# Equipment slots (Authentic Swordigo: Weapon, Armor, Amulet/Pendant, Ring 1, Ring 2, Trinket/Charm)
var equipped_weapon: String = "brass_sword"
var equipped_armor: String = "cloth_tunic"
var equipped_amulet: String = ""
var equipped_ring_1: String = ""
var equipped_ring_2: String = ""
var equipped_trinket: String = ""

# Unlocked magic abilities
var unlocked_spells: Array[String] = ["magic_bolt"]
var active_spell_index: int = 0

# Consumables and items: Array of { "id": String, "count": int }
var items: Array[Dictionary] = [
	{"id": "healing_potion", "count": 2},
	{"id": "mana_potion", "count": 1}
]

# Key items (including Mageblade Iselon Shards 1..4)
var key_items: Array[String] = []

# Database of item definitions (Authentic Swordigo Roster)
var item_definitions: Dictionary = {
	# Authentic Weapons
	"brass_sword": {
		"name": "Brass Sword",
		"type": "weapon",
		"attack_bonus": 5,
		"magic_bonus": 0,
		"defense_bonus": 0,
		"description": "An old training blade given to you by the Master in Cairnwood.",
		"value": 15
	},
	"broadsword": {
		"name": "Broadsword",
		"type": "weapon",
		"attack_bonus": 12,
		"magic_bonus": 0,
		"defense_bonus": 0,
		"description": "A heavier blade with a wide edge, capable of cleaving multiple foes.",
		"value": 60
	},
	"iron_sword": {
		"name": "Iron Sword",
		"type": "weapon",
		"attack_bonus": 18,
		"magic_bonus": 0,
		"defense_bonus": 0,
		"description": "A well-forged traveler's blade. Standard issue for village guardians.",
		"value": 120
	},
	"magic_sword": {
		"name": "Magic Sword",
		"type": "weapon",
		"attack_bonus": 28,
		"magic_bonus": 15,
		"defense_bonus": 0,
		"description": "An enchanted blade that resonates with arcane energy found in ancient ruins.",
		"value": 250
	},
	"the_mageblade": {
		"name": "The Mageblade",
		"type": "weapon",
		"attack_bonus": 50,
		"magic_bonus": 35,
		"defense_bonus": 5,
		"description": "The legendary blade reforged from the four Iselon Shards to banish the Corruptor.",
		"value": 999
	},
	# Authentic Armors
	"cloth_tunic": {
		"name": "Traveler's Tunic",
		"type": "armor",
		"defense_bonus": 1,
		"health_bonus": 0,
		"description": "Simple cloth garments worn by apprentices in Cairnwood.",
		"value": 10
	},
	"leather_armor": {
		"name": "Leather Armor",
		"type": "armor",
		"defense_bonus": 4,
		"health_bonus": 25,
		"description": "Sturdy boiled leather providing lightweight protection.",
		"value": 50
	},
	"knight_plate": {
		"name": "Knight's Plate",
		"type": "armor",
		"defense_bonus": 10,
		"health_bonus": 60,
		"description": "Heavy steel armor forged to withstand crushing strikes from corrupt knights.",
		"value": 200
	},
	# Authentic Baubles & Trinkets
	"fiery_pendant": {
		"name": "Fiery Pendant",
		"type": "amulet",
		"defense_bonus": 2,
		"magic_bonus": 5,
		"health_bonus": 10,
		"description": "Grants immunity to fire and burning lava hazards.",
		"value": 100
	},
	"vitality_ring": {
		"name": "Vitality Ring",
		"type": "ring",
		"attack_bonus": 0,
		"magic_bonus": 0,
		"defense_bonus": 2,
		"health_bonus": 20,
		"description": "Slowly regenerates health over time.",
		"value": 80
	},
	"magic_ring": {
		"name": "Magic Ring",
		"type": "ring",
		"attack_bonus": 0,
		"magic_bonus": 10,
		"defense_bonus": 0,
		"description": "Significantly accelerates mana recovery.",
		"value": 85
	},
	"magnet_ring": {
		"name": "Magnet Ring",
		"type": "ring",
		"attack_bonus": 0,
		"magic_bonus": 0,
		"defense_bonus": 0,
		"description": "Naturally draws nearby soul shards toward the hero.",
		"value": 60
	},
	"infinity_charm": {
		"name": "Infinity Charm",
		"type": "trinket",
		"attack_bonus": 5,
		"magic_bonus": 10,
		"defense_bonus": 5,
		"description": "A legendary relic that repels non-physical corrupt magic.",
		"value": 300
	},
	# Authentic Consumables
	"healing_potion": {
		"name": "Healing Potion",
		"type": "consumable",
		"heal_amount": 50,
		"description": "Restores 50 points of Health.",
		"value": 15
	},
	"health_potion": {
		"name": "Healing Potion",
		"type": "consumable",
		"heal_amount": 50,
		"description": "Restores 50 points of Health.",
		"value": 15
	},
	"mana_potion": {
		"name": "Mana Potion",
		"type": "consumable",
		"mana_amount": 40,
		"description": "Restores 40 points of Mana.",
		"value": 20
	},
	# Authentic Key Items & Mageblade Shards
	"cairnwood_key": {
		"name": "Cairnwood Gate Key",
		"type": "key",
		"description": "The iron key that unlocks the passage from Cairnwood Forest to the Village.",
		"value": 0
	},
	"old_dungeon_key": {
		"name": "Ancient Crypt Key",
		"type": "key",
		"description": "Opens the sealed crypts.",
		"value": 0
	},
	"iselon_shard_1": {
		"name": "Mageblade Shard (Hilt)",
		"type": "key",
		"description": "The first shard of the legendary Mageblade, recovered from the Corruptor's crypt.",
		"value": 0
	},
	"iselon_shard_2": {
		"name": "Mageblade Shard (Crossguard)",
		"type": "key",
		"description": "The second shard of the Mageblade, discovered in the icy peaks.",
		"value": 0
	},
	"iselon_shard_3": {
		"name": "Mageblade Shard (Lower Blade)",
		"type": "key",
		"description": "The third shard of the Mageblade, recovered from the fiery depths.",
		"value": 0
	},
	"iselon_shard_4": {
		"name": "Mageblade Shard (Blade Tip)",
		"type": "key",
		"description": "The final shard of the Mageblade, guarded at World's End.",
		"value": 0
	}
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func add_coins(amount: int) -> void:
	coins += amount
	if coins < 0:
		coins = 0
	coins_changed.emit(coins)

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		coins_changed.emit(coins)
		return true
	return false

func add_soul_shards(amount: int) -> void:
	soul_shards += amount
	soul_shards_changed.emit(soul_shards)

func add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next:
		xp -= xp_to_next
		level += 1
		xp_to_next = int(xp_to_next * 1.5)
		unspent_stat_points += 1
		base_max_health += 15
		base_max_mana += 10
		base_attack += 3
		base_defense += 1
		base_magic += 2
		level_up.emit(level)
		var gm = get_node_or_null("/root/GameManager")
		if gm and gm.player and gm.player.has_method("on_level_up"):
			gm.player.on_level_up()

func add_item(item_id: String, count: int = 1) -> void:
	if not item_definitions.has(item_id):
		return
	var item_type = item_definitions[item_id].get("type", "misc")
	if item_type == "key":
		if not key_items.has(item_id):
			key_items.append(item_id)
		inventory_updated.emit()
		return

	for entry in items:
		if entry["id"] == item_id:
			entry["count"] += count
			inventory_updated.emit()
			return
	items.append({"id": item_id, "count": count})
	inventory_updated.emit()

func remove_item(item_id: String, count: int = 1) -> bool:
	for i in range(items.size()):
		if items[i]["id"] == item_id:
			if items[i]["count"] >= count:
				items[i]["count"] -= count
				if items[i]["count"] <= 0:
					items.remove_at(i)
				inventory_updated.emit()
				return true
			return false
	return false

func has_item(item_id: String, count: int = 1) -> bool:
	if key_items.has(item_id):
		return true
	for entry in items:
		if entry["id"] == item_id and entry["count"] >= count:
			return true
	return false

func equip_item(slot: String, item_id: String) -> bool:
	if item_id != "" and not item_definitions.has(item_id):
		return false

	match slot:
		"weapon":
			equipped_weapon = item_id
		"armor":
			equipped_armor = item_id
		"amulet":
			equipped_amulet = item_id
		"ring_1":
			equipped_ring_1 = item_id
		"ring_2":
			equipped_ring_2 = item_id
		"trinket":
			equipped_trinket = item_id
		_:
			return false

	equipment_changed.emit(slot, item_id)
	return true

func unlock_spell(spell_id: String) -> void:
	if not unlocked_spells.has(spell_id):
		unlocked_spells.append(spell_id)

func cycle_spell() -> String:
	if unlocked_spells.is_empty():
		return ""
	active_spell_index = (active_spell_index + 1) % unlocked_spells.size()
	var spell = unlocked_spells[active_spell_index]
	spell_changed.emit(spell)
	return spell

func get_active_spell() -> String:
	if unlocked_spells.is_empty():
		return ""
	return unlocked_spells[active_spell_index]

# Stat calculations
func get_total_max_health() -> int:
	var total = base_max_health
	for slot in [equipped_armor, equipped_amulet]:
		if slot != "" and item_definitions.has(slot):
			total += item_definitions[slot].get("health_bonus", 0)
	return total

func get_total_max_mana() -> int:
	var total = base_max_mana
	for slot in [equipped_amulet, equipped_ring_1, equipped_ring_2]:
		if slot != "" and item_definitions.has(slot):
			total += item_definitions[slot].get("mana_bonus", 0)
	return total

func get_total_attack() -> int:
	var total = base_attack
	for slot in [equipped_weapon, equipped_ring_1, equipped_ring_2]:
		if slot != "" and item_definitions.has(slot):
			total += item_definitions[slot].get("attack_bonus", 0)
	return total

func get_total_defense() -> int:
	var total = base_defense
	for slot in [equipped_armor, equipped_amulet, equipped_ring_1, equipped_ring_2]:
		if slot != "" and item_definitions.has(slot):
			total += item_definitions[slot].get("defense_bonus", 0)
	return total

func get_total_magic() -> int:
	var total = base_magic
	for slot in [equipped_weapon, equipped_amulet, equipped_ring_1, equipped_ring_2]:
		if slot != "" and item_definitions.has(slot):
			total += item_definitions[slot].get("magic_bonus", 0)
	return total

func reset_to_defaults() -> void:
	coins = 50
	soul_shards = 0
	level = 1
	xp = 0
	xp_to_next = 100
	base_max_health = 100
	base_max_mana = 50
	base_attack = 10
	base_defense = 2
	base_magic = 10
	equipped_weapon = "brass_sword"
	equipped_armor = "cloth_tunic"
	equipped_amulet = ""
	equipped_ring_1 = ""
	equipped_ring_2 = ""
	equipped_trinket = ""
	unlocked_spells = ["magic_bolt"]
	active_spell_index = 0
	items = [
		{"id": "healing_potion", "count": 2},
		{"id": "mana_potion", "count": 1}
	]
	key_items = []
	unspent_stat_points = 0

func reset() -> void:
	reset_to_defaults()

func get_shard_count() -> int:
	var count = 0
	for i in range(1, 5):
		if key_items.has("iselon_shard_%d" % i):
			count += 1
	return count

func is_mageblade_complete() -> bool:
	return get_shard_count() == 4

func add_key_item(item_id: String) -> void:
	if not key_items.has(item_id):
		key_items.append(item_id)
		inventory_updated.emit()

func equip_weapon(item_id: String) -> bool:
	return equip_item("weapon", item_id)
