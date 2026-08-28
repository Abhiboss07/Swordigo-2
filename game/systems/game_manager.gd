extends Node

## GameManager
## Central singleton tracking world lifecycle, player registration, active campaign mode,
## pause states, checkpoint persistence, and boss signals.

enum CampaignMode {
	CLASSIC_CAMPAIGN, # 100% authentic Swordigo baseline
	SEQUEL_EXPANSION  # Additive post-game sequel content
}

signal player_health_changed(current: int, maximum: int)
signal player_mana_changed(current: int, maximum: int)
signal player_died
signal checkpoint_activated(checkpoint_name: String, position: Vector3)
signal boss_engaged(boss_name: String, max_health: int)
signal boss_health_updated(current_health: int, max_health: int)
signal boss_health_changed(boss_name: String, current_health: int, max_health: int)
signal coins_changed(new_amount: int)
signal boss_defeated(boss_name: String)
signal game_paused(paused: bool)
signal campaign_mode_changed(new_mode: CampaignMode)

var current_campaign_mode: CampaignMode = CampaignMode.CLASSIC_CAMPAIGN

var campaign_mode: int:
	get:
		return int(current_campaign_mode)
	set(val):
		current_campaign_mode = val as CampaignMode
		campaign_mode_changed.emit(current_campaign_mode)

var player: CharacterBody3D = null
var current_zone_path: String = "res://scenes/original_campaign/cairnwood_forest_part1.tscn"
var current_spawn_marker: String = "Spawn_Default"

var active_checkpoint_zone: String = "res://scenes/original_campaign/cairnwood_forest_part1.tscn"
var active_checkpoint_pos: Vector3 = Vector3(0.0, 1.5, 0.0)
var active_checkpoint_id: String = "default"

var checkpoint_position: Vector3:
	get:
		return active_checkpoint_pos

func register_checkpoint(cp_id: String, pos: Vector3, zone_path: String) -> void:
	set_checkpoint(zone_path, pos, cp_id)

var is_paused: bool = false
var is_game_over: bool = false
var playtime_seconds: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if not is_paused and not is_game_over:
		playtime_seconds += delta

func register_player(p: CharacterBody3D) -> void:
	player = p

func set_campaign_mode(mode: CampaignMode) -> void:
	current_campaign_mode = mode
	campaign_mode_changed.emit(mode)

func set_checkpoint(zone_path: String, pos: Vector3, checkpoint_id: String) -> void:
	active_checkpoint_zone = zone_path
	active_checkpoint_pos = pos
	active_checkpoint_id = checkpoint_id
	checkpoint_activated.emit(checkpoint_id, pos)
	if has_node("/root/SaveSystem"):
		var save_sys = get_node("/root/SaveSystem")
		if save_sys.has_method("auto_save"):
			save_sys.auto_save()

func trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	player_died.emit()

func respawn_player() -> void:
	is_game_over = false
	if active_checkpoint_zone != "":
		current_zone_path = active_checkpoint_zone
		current_spawn_marker = "checkpoint"
		if has_node("/root/SceneTransition"):
			get_node("/root/SceneTransition").transition_to_scene(active_checkpoint_zone, "checkpoint")
		else:
			get_tree().change_scene_to_file(active_checkpoint_zone)

func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	game_paused.emit(is_paused)

func set_pause(paused: bool) -> void:
	is_paused = paused
	get_tree().paused = is_paused
	game_paused.emit(is_paused)

func reset_session() -> void:
	is_game_over = false
	is_paused = false
	get_tree().paused = false
	playtime_seconds = 0.0
	current_campaign_mode = CampaignMode.CLASSIC_CAMPAIGN
	current_zone_path = "res://scenes/original_campaign/cairnwood_forest_part1.tscn"
	current_spawn_marker = "Spawn_Default"
	active_checkpoint_zone = current_zone_path
	active_checkpoint_pos = Vector3(0.0, 1.5, 0.0)
	active_checkpoint_id = "default"
