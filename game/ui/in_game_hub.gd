extends Control

const SwordigoTheme = preload("res://systems/swordigo_theme.gd")

## InGameHub Controller (Authentic Swordigo 6-Tab In-Game Dock)
## Reconstructs the authentic Swordigo pause & management hub with 6 left vertical dock tabs:
## 1. Character, 2. Inventory, 3. World Map, 4. Quests, 5. Settings, 6. Return.

@onready var character_panel: Control = $ContentPanel/CharacterTab
@onready var inventory_panel: Control = $ContentPanel/InventoryTab
@onready var map_panel: Control = $ContentPanel/WorldMapTab
@onready var quests_panel: Control = $ContentPanel/QuestsTab
@onready var settings_panel: Control = $ContentPanel/SettingsTab

# Tab Buttons
@onready var tab_character_btn: Button = $DockMargin/DockVBox/TabCharacter
@onready var tab_inventory_btn: Button = $DockMargin/DockVBox/TabInventory
@onready var tab_map_btn: Button = $DockMargin/DockVBox/TabMap
@onready var tab_quests_btn: Button = $DockMargin/DockVBox/TabQuests
@onready var tab_settings_btn: Button = $DockMargin/DockVBox/TabSettings
@onready var tab_back_btn: Button = $DockMargin/DockVBox/TabBack

# Character Tab labels
@onready var char_level_label: Label = $ContentPanel/CharacterTab/VBox/LevelLabel
@onready var char_xp_bar: ProgressBar = $ContentPanel/CharacterTab/VBox/XpBar
@onready var char_hp_val: Label = $ContentPanel/CharacterTab/VBox/StatsGrid/HpVal
@onready var char_atk_val: Label = $ContentPanel/CharacterTab/VBox/StatsGrid/AtkVal
@onready var char_mag_val: Label = $ContentPanel/CharacterTab/VBox/StatsGrid/MagVal
@onready var shard_slots: Array[Label] = [
	$ContentPanel/CharacterTab/VBox/MagebladeSection/ShardsHBox/Shard1,
	$ContentPanel/CharacterTab/VBox/MagebladeSection/ShardsHBox/Shard2,
	$ContentPanel/CharacterTab/VBox/MagebladeSection/ShardsHBox/Shard3,
	$ContentPanel/CharacterTab/VBox/MagebladeSection/ShardsHBox/Shard4
]

# Inventory Tab nodes
@onready var inv_weapon_label: Label = $ContentPanel/InventoryTab/VBox/EquipCards/WeaponCard/Val
@onready var inv_armor_label: Label = $ContentPanel/InventoryTab/VBox/EquipCards/ArmorCard/Val
@onready var inv_spell_label: Label = $ContentPanel/InventoryTab/VBox/EquipCards/SpellCard/Val
@onready var inv_trinket1_label: Label = $ContentPanel/InventoryTab/VBox/EquipCards/Trinket1Card/Val
@onready var inv_trinket2_label: Label = $ContentPanel/InventoryTab/VBox/EquipCards/Trinket2Card/Val
@onready var inv_item_list: ItemList = $ContentPanel/InventoryTab/VBox/ItemsHBox/ItemList
@onready var inv_use_btn: Button = $ContentPanel/InventoryTab/VBox/ItemsHBox/UseBtn

# Quests Tab nodes
@onready var quests_vbox: VBoxContainer = $ContentPanel/QuestsTab/Scroll/QuestsVBox

# Settings Tab nodes
@onready var sfx_slider: HSlider = $ContentPanel/SettingsTab/VBox/SfxSlider
@onready var music_slider: HSlider = $ContentPanel/SettingsTab/VBox/MusicSlider
@onready var save_game_btn: Button = $ContentPanel/SettingsTab/VBox/SaveGameBtn
@onready var title_btn: Button = $ContentPanel/SettingsTab/VBox/TitleBtn
@onready var save_status_label: Label = $ContentPanel/SettingsTab/VBox/SaveStatusLabel

func _ready() -> void:
	visible = false

	tab_character_btn.pressed.connect(func(): _switch_tab(0))
	tab_inventory_btn.pressed.connect(func(): _switch_tab(1))
	tab_map_btn.pressed.connect(func(): _switch_tab(2))
	tab_quests_btn.pressed.connect(func(): _switch_tab(3))
	tab_settings_btn.pressed.connect(func(): _switch_tab(4))
	tab_back_btn.pressed.connect(close_hub)

	if inv_use_btn:
		inv_use_btn.pressed.connect(_on_use_item_pressed)
	if save_game_btn:
		save_game_btn.pressed.connect(_on_save_pressed)
	if title_btn:
		title_btn.pressed.connect(_on_return_title_pressed)

	if sfx_slider and has_node("/root/AudioManager"):
		sfx_slider.value_changed.connect(func(val): AudioManager.sfx_volume_db = linear_to_db(val / 100.0))
	if music_slider and has_node("/root/AudioManager"):
		music_slider.value_changed.connect(func(val): AudioManager.music_volume_db = linear_to_db(val / 100.0))

	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if visible:
		_switch_tab(0)
		_refresh_character_tab()
		_refresh_inventory_tab()
		_refresh_quests_tab()

func _switch_tab(tab_idx: int) -> void:
	character_panel.visible = (tab_idx == 0)
	inventory_panel.visible = (tab_idx == 1)
	map_panel.visible = (tab_idx == 2)
	quests_panel.visible = (tab_idx == 3)
	settings_panel.visible = (tab_idx == 4)

	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("switch")

func close_hub() -> void:
	visible = false
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.set_pause(false)

func _refresh_character_tab() -> void:
	var inv = get_node_or_null("/root/Inventory")
	if not inv:
		return
	char_level_label.text = "Hero — Level %d" % inv.level
	char_xp_bar.max_value = inv.xp_to_next
	char_xp_bar.value = inv.xp
	char_hp_val.text = "%d HP" % inv.get_total_max_health()
	char_atk_val.text = "%d Damage" % inv.get_total_attack()
	char_mag_val.text = "%d Power" % inv.get_total_magic()

	for i in range(4):
		var shard_id = "iselon_shard_%d" % (i + 1)
		if inv.has_item(shard_id):
			shard_slots[i].modulate = SwordigoTheme.COLOR_SHARD_CYAN
			shard_slots[i].text = "[ Shard %d: Found ]" % (i + 1)
		else:
			shard_slots[i].modulate = Color(0.4, 0.4, 0.4)
			shard_slots[i].text = "[ Shard %d: Missing ]" % (i + 1)

func _refresh_inventory_tab() -> void:
	var inv = get_node_or_null("/root/Inventory")
	if not inv:
		return
	inv_weapon_label.text = _get_item_name(inv.equipped_weapon)
	inv_armor_label.text = _get_item_name(inv.equipped_armor)
	inv_spell_label.text = inv.get_active_spell().replace("_", " ").capitalize()
	inv_trinket1_label.text = _get_item_name(inv.equipped_amulet)
	inv_trinket2_label.text = _get_item_name(inv.equipped_ring_1)

	inv_item_list.clear()
	for entry in inv.items:
		var item_name = _get_item_name(entry["id"])
		inv_item_list.add_item("%s (x%d)" % [item_name, entry["count"]])

	for key in inv.key_items:
		inv_item_list.add_item("🔑 " + _get_item_name(key))

func _refresh_quests_tab() -> void:
	var qm = get_node_or_null("/root/QuestManager")
	if not qm:
		return
	for child in quests_vbox.get_children():
		child.queue_free()

	for q_id in qm.active_quests.keys():
		var q_data = qm.quest_definitions.get(q_id, {})
		var lbl = Label.new()
		lbl.text = "• " + q_data.get("title", q_id)
		lbl.modulate = SwordigoTheme.COLOR_GOLD_PRIMARY
		quests_vbox.add_child(lbl)

		var desc = Label.new()
		var stage = qm.active_quests[q_id]
		var stages = q_data.get("stages", [])
		var stage_text = stages[stage]["objective"] if stage < stages.size() else ""
		desc.text = "  Objective: " + stage_text
		desc.modulate = Color(0.85, 0.85, 0.85)
		quests_vbox.add_child(desc)

	for q_id in qm.completed_quests:
		var q_data = qm.quest_definitions.get(q_id, {})
		var lbl = Label.new()
		lbl.text = "✓ " + q_data.get("title", q_id) + " (Completed)"
		lbl.modulate = Color(0.4, 0.85, 0.4)
		quests_vbox.add_child(lbl)

func _get_item_name(id: String) -> String:
	var inv = get_node_or_null("/root/Inventory")
	if id == "" or not inv or not inv.item_definitions.has(id):
		return "None"
	return inv.item_definitions[id].get("name", id)

func _on_use_item_pressed() -> void:
	var inv = get_node_or_null("/root/Inventory")
	var gm = get_node_or_null("/root/GameManager")
	if not inv or not gm:
		return

	var selected = inv_item_list.get_selected_items()
	if selected.is_empty():
		return
	var idx = selected[0]
	if idx < inv.items.size():
		var entry = inv.items[idx]
		var def = inv.item_definitions.get(entry["id"], {})
		if def.get("type") == "consumable" and gm.player and is_instance_valid(gm.player):
			if def.has("heal_amount"):
				gm.player.heal(def["heal_amount"])
				inv.remove_item(entry["id"], 1)
			elif def.has("mana_amount"):
				gm.player.restore_mana(def["mana_amount"])
				inv.remove_item(entry["id"], 1)
			if has_node("/root/AudioManager"):
				AudioManager.play_sfx("magic")
			_refresh_inventory_tab()
			_refresh_character_tab()

func _on_save_pressed() -> void:
	if has_node("/root/SaveSystem"):
		SaveSystem.auto_save()
		save_status_label.text = "Game Saved!"
		var tween = create_tween()
		tween.tween_property(save_status_label, "modulate:a", 1.0, 0.2)
		tween.tween_interval(1.5)
		tween.tween_property(save_status_label, "modulate:a", 0.0, 0.5)

func _on_return_title_pressed() -> void:
	close_hub()
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.reset_session()
	if has_node("/root/SceneTransition"):
		SceneTransition.transition_to_scene("res://ui/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
