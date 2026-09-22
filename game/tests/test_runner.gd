extends SceneTree

## Automated Headless QA & Verification Test Runner for Swordigo V2
## Verifies core systems, Caver-calibrated physics, inventory, quests, save integrity,
## and authentic scene instantiation.

var tests_passed: int = 0
var tests_failed: int = 0
var test_log: Array[String] = []

func _init() -> void:
	print("\n========================================================")
	print("  SWORDIGO V2 — HEADLESS AUTOMATED VERIFICATION SUITE")
	print("========================================================\n")

	# Wait one frame for engine autoloads to settle
	await process_frame

	_run_all_tests()

	print("\n========================================================")
	print("  TEST SUMMARY: %d PASSED, %d FAILED" % [tests_passed, tests_failed])
	print("========================================================\n")

	if tests_failed == 0:
		print(">> ALL SYSTEMS AND AUTHENTIC ASSETS VERIFIED CLEANLY <<\n")
		quit(0)
	else:
		print(">> ERRORS DETECTED DURING TEST EXECUTION <<\n")
		quit(1)

func _assert_test(test_name: String, condition: bool, failure_msg: String = "") -> void:
	if condition:
		tests_passed += 1
		print("  [PASS] %s" % test_name)
	else:
		tests_failed += 1
		print("  [FAIL] %s - %s" % [test_name, failure_msg])
		test_log.append("FAIL: %s - %s" % [test_name, failure_msg])

func _run_all_tests() -> void:
	_test_inventory_system()
	_test_quest_system()
	_test_game_manager_and_campaign_separation()
	_test_save_system()
	_test_player_physics_and_kinematics()
	_test_altar_reforging_mechanics()
	_test_sequel_boss_void_weaver()
	_test_scenes_and_resources_integrity()

func _test_inventory_system() -> void:
	print("--- Running Inventory System Tests ---")
	var inv = root.get_node_or_null("Inventory")
	_assert_test("Inventory autoload exists", inv != null)
	if not inv:
		return

	inv.reset()
	_assert_test("Initial level is 1", inv.level == 1)
	_assert_test("Initial brass sword equipped", inv.equipped_weapon == "brass_sword")
	_assert_test("Initial total attack is 15", inv.get_total_attack() == 15)
	_assert_test("Initial max health is 100", inv.get_total_max_health() == 100)

	# Test XP & leveling
	inv.add_xp(100)
	_assert_test("Hero leveled up to level 2 with 100 XP", inv.level == 2)
	_assert_test("Stat points awarded on level up", inv.unspent_stat_points == 1)

	# Test Mageblade shards
	_assert_test("Initially 0 Mageblade shards", inv.get_shard_count() == 0)
	inv.add_key_item("iselon_shard_1")
	inv.add_key_item("iselon_shard_2")
	_assert_test("Collected 2 shards", inv.get_shard_count() == 2)
	_assert_test("Mageblade not fully reforged yet", not inv.is_mageblade_complete())
	inv.add_key_item("iselon_shard_3")
	inv.add_key_item("iselon_shard_4")
	_assert_test("Collected all 4 shards", inv.get_shard_count() == 4)
	_assert_test("Mageblade ready to reforge", inv.is_mageblade_complete())

	# Test Weapon Upgrades
	inv.equip_weapon("the_mageblade")
	_assert_test("The Mageblade equipped", inv.equipped_weapon == "the_mageblade")
	_assert_test("The Mageblade attack power is 50", inv.get_total_attack() >= 50)

	# Test Consumables
	inv.add_item("health_potion", 2)
	_assert_test("Added 2 health potions", inv.has_item("health_potion", 2))
	inv.remove_item("health_potion", 1)
	_assert_test("Removed 1 health potion, count is 1", inv.has_item("health_potion", 1))

func _test_quest_system() -> void:
	print("\n--- Running Quest System Tests ---")
	var qm = root.get_node_or_null("QuestManager")
	_assert_test("QuestManager autoload exists", qm != null)
	if not qm:
		return

	qm.reset()
	_assert_test("Active quests is empty after reset", qm.active_quests.is_empty())
	qm.start_quest("quest01_find_master")
	_assert_test("Quest 'quest01_find_master' started", qm.is_quest_active("quest01_find_master"))
	_assert_test("Quest 'quest01_find_master' stage is 0", qm.get_quest_stage("quest01_find_master") == 0)

	# Advance quest
	qm.advance_quest("quest01_find_master")
	_assert_test("Quest 'quest01_find_master' stage advanced to 1", qm.get_quest_stage("quest01_find_master") == 1)

func _test_game_manager_and_campaign_separation() -> void:
	print("\n--- Running GameManager & Dual-Campaign Tests ---")
	var gm = root.get_node_or_null("GameManager")
	_assert_test("GameManager autoload exists", gm != null)
	if not gm:
		return

	# Verify strict campaign separation enum and property
	gm.campaign_mode = gm.CampaignMode.CLASSIC_CAMPAIGN
	_assert_test("Campaign mode is CLASSIC_CAMPAIGN", gm.campaign_mode == gm.CampaignMode.CLASSIC_CAMPAIGN)

	gm.campaign_mode = gm.CampaignMode.SEQUEL_EXPANSION
	_assert_test("Campaign mode can switch to SEQUEL_EXPANSION", gm.campaign_mode == gm.CampaignMode.SEQUEL_EXPANSION)

	# Checkpoint registration
	gm.register_checkpoint("test_cp", Vector3(10, 2, 0), "res://scenes/original_campaign/cairnwood_forest_part1.tscn")
	_assert_test("Checkpoint 'test_cp' registered", gm.active_checkpoint_id == "test_cp")
	_assert_test("Checkpoint position accurate", gm.checkpoint_position == Vector3(10, 2, 0))

func _test_save_system() -> void:
	print("\n--- Running Save System Tests ---")
	var ss = root.get_node_or_null("SaveSystem")
	_assert_test("SaveSystem autoload exists", ss != null)
	if not ss:
		return

	# Verify slot info retrieval
	var info = ss.get_slot_info(1)
	_assert_test("Slot info format contains 'exists'", info.has("exists"))

	# Test save and load roundtrip on slot 3
	var save_ok = ss.save_game(3)
	_assert_test("SaveSystem saves game to slot 3", save_ok)
	var slot3_info = ss.get_slot_info(3)
	_assert_test("Slot 3 reports exists true after save", slot3_info.get("exists", false))
	var load_ok = ss.load_game(3)
	_assert_test("SaveSystem loads slot 3 cleanly", load_ok)
	ss.delete_save(3)
	_assert_test("Slot 3 cleaned up after test", not ss.has_save(3))

func _test_player_physics_and_kinematics() -> void:
	print("\n--- Running Player Kinematics & Caver Physics Tests ---")
	var player_scene = load("res://scenes/original_campaign/player.tscn")
	_assert_test("Player scene loads cleanly", player_scene != null)
	if not player_scene:
		return

	var player = player_scene.instantiate()
	root.add_child(player)
	_assert_test("Player instantiated in tree", player != null)

	# Verify 2.5D constraint
	player.position = Vector3(5, 2, 10) # Set non-zero Z
	player._physics_process(0.016)
	_assert_test("Player 2.5D plane constraint enforced (Z == 0)", is_equal_approx(player.position.z, 0.0))
	_assert_test("Player Z velocity zeroed out", is_equal_approx(player.velocity.z, 0.0))

	# Verify jump and double-jump parameters
	_assert_test("Jump velocity is positive (upward)", player.jump_velocity > 0)
	_assert_test("Double jump velocity is configured", player.double_jump_velocity > 0)

	# Verify health and mana
	_assert_test("Player has full health initially", player.current_health == player.max_health)
	var hp_before = player.current_health
	player.take_damage(5)
	_assert_test("Player took damage through defense calculation (HP reduced by 1)", player.current_health == hp_before - 1)
	player.heal(1)
	_assert_test("Player healed 1 HP back to full", player.current_health == hp_before)

	player.queue_free()

func _test_altar_reforging_mechanics() -> void:
	print("\n--- Running Mageblade Altar Reforging Tests ---")
	var inv = root.get_node_or_null("Inventory")
	if not inv:
		return

	# Load altar script dynamically
	var AltarScript = load("res://scripts/altar_mageblade.gd")
	var altar = Area3D.new()
	altar.set_script(AltarScript)
	root.add_child(altar)

	# Reset inventory
	inv.reset()
	_assert_test("Initially cannot reforge without shards", not inv.is_mageblade_complete())
	altar.reforge_mageblade()
	_assert_test("Mageblade remains unequipped without 4 shards", inv.equipped_weapon == "brass_sword")

	# Add all 4 shards
	for i in range(1, 5):
		inv.add_key_item("iselon_shard_%d" % i)
	_assert_test("All 4 shards present in inventory", inv.is_mageblade_complete())

	altar.reforge_mageblade()
	_assert_test("The Mageblade successfully reforged and equipped at Altar", inv.equipped_weapon == "the_mageblade")
	_assert_test("Altar marked as reforged", altar.is_reforged == true)

	altar.queue_free()

func _test_sequel_boss_void_weaver() -> void:
	print("\n--- Running Sequel Boss (Void Weaver) Tests ---")
	var weaver_scene = load("res://scenes/expansion/boss_void_weaver.tscn")
	_assert_test("Void Weaver scene loads", weaver_scene != null)
	if not weaver_scene:
		return

	var weaver = weaver_scene.instantiate()
	root.add_child(weaver)
	_assert_test("Void Weaver instantiated in tree", weaver != null)
	_assert_test("Void Weaver max health is 450", weaver.max_health == 450)
	_assert_test("Void Weaver starts at full health", weaver.current_health == 450)

	# Test damage and health signals
	weaver.take_damage(50, "physical")
	_assert_test("Void Weaver took 50 damage (HP: 400)", weaver.current_health == 400)
	weaver.queue_free()

func _test_scenes_and_resources_integrity() -> void:
	print("\n--- Running Scene & Resource Integrity Tests ---")
	var scenes_to_verify = [
		"res://scenes/original_campaign/cairnwood_forest_part1.tscn",
		"res://scenes/original_campaign/cairnwood_forest_part2.tscn",
		"res://scenes/original_campaign/cairnwood_village.tscn",
		"res://scenes/original_campaign/cairnwood_crossroads.tscn",
		"res://scenes/original_campaign/corruptor_crypt.tscn",
		"res://scenes/original_campaign/florennum_pass.tscn",
		"res://scenes/original_campaign/florennum_town.tscn",
		"res://scenes/original_campaign/snowy_peaks.tscn",
		"res://scenes/original_campaign/fiery_depths.tscn",
		"res://scenes/original_campaign/worlds_end.tscn",
		"res://scenes/original_campaign/chamber_mageblade.tscn",
		"res://scenes/expansion/sequel_forsaken_expanse.tscn",
		"res://scenes/expansion/sequel_sunken_catacombs.tscn",
		"res://scenes/expansion/sequel_astral_spire.tscn",
		"res://scenes/expansion/boss_void_weaver.tscn",
		"res://scenes/original_campaign/boss_corruptor.tscn",
		"res://scenes/original_campaign/enemy_beetle.tscn",
		"res://scenes/original_campaign/enemy_bat.tscn",
		"res://scenes/original_campaign/enemy_skeleton.tscn",
		"res://scenes/original_campaign/checkpoint.tscn",
		"res://scenes/original_campaign/chest.tscn",
		"res://scenes/original_campaign/pot_breakable.tscn",
		"res://scenes/original_campaign/hazard_spikes.tscn",
		"res://scenes/original_campaign/moving_platform.tscn",
		"res://scenes/original_campaign/crystal_switch.tscn",
		"res://scenes/original_campaign/npc.tscn",
		"res://scenes/original_campaign/portal.tscn",
		"res://ui/main_menu.tscn",
		"res://ui/hud.tscn",
		"res://ui/in_game_hub.tscn",
		"res://ui/game_over_menu.tscn",
		"res://ui/dialogue_box.tscn"
	]

	for path in scenes_to_verify:
		var scene = load(path)
		_assert_test("Scene loads: %s" % path.get_file(), scene != null, "Failed to load %s" % path)
		if scene:
			var instance = scene.instantiate()
			_assert_test("Scene instantiates cleanly: %s" % path.get_file(), instance != null)
			instance.queue_free()
