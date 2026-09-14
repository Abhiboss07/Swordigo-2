extends Control

const SwordigoTheme = preload("res://systems/swordigo_theme.gd")

## MainMenu Controller
## Authentic Swordigo Title Screen with save slot selection, campaign mode selection
## (Classic Campaign vs Sequel Expansion), and audio settings.

@onready var title_panel: Control = $TitlePanel
@onready var slot_select_panel: Control = $SlotSelectPanel
@onready var settings_panel: Control = $SettingsPanel

# Title buttons
@onready var play_btn: Button = $TitlePanel/VBox/PlayBtn
@onready var sequel_btn: Button = $TitlePanel/VBox/SequelBtn
@onready var settings_btn: Button = $TitlePanel/VBox/SettingsBtn
@onready var quit_btn: Button = $TitlePanel/VBox/QuitBtn

# Slot buttons
@onready var slot1_btn: Button = $SlotSelectPanel/VBox/Slot1Btn
@onready var slot2_btn: Button = $SlotSelectPanel/VBox/Slot2Btn
@onready var slot3_btn: Button = $SlotSelectPanel/VBox/Slot3Btn
@onready var slot_back_btn: Button = $SlotSelectPanel/VBox/BackBtn

# Settings
@onready var sfx_slider: HSlider = $SettingsPanel/VBox/SfxSlider
@onready var music_slider: HSlider = $SettingsPanel/VBox/MusicSlider
@onready var settings_back_btn: Button = $SettingsPanel/VBox/BackBtn

var chosen_campaign_mode = 0 # 0 = CLASSIC_CAMPAIGN, 1 = SEQUEL_EXPANSION

func _ready() -> void:
	title_panel.visible = true
	slot_select_panel.visible = false
	settings_panel.visible = false

	play_btn.pressed.connect(_on_play_classic_pressed)
	sequel_btn.pressed.connect(_on_play_sequel_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	if quit_btn:
		quit_btn.pressed.connect(func(): get_tree().quit())

	slot1_btn.pressed.connect(func(): _load_slot(1))
	slot2_btn.pressed.connect(func(): _load_slot(2))
	slot3_btn.pressed.connect(func(): _load_slot(3))
	slot_back_btn.pressed.connect(_show_title)

	settings_back_btn.pressed.connect(_show_title)

	if sfx_slider and has_node("/root/AudioManager"):
		sfx_slider.value_changed.connect(func(v): AudioManager.sfx_volume_db = linear_to_db(v / 100.0))
	if music_slider and has_node("/root/AudioManager"):
		music_slider.value_changed.connect(func(v): AudioManager.music_volume_db = linear_to_db(v / 100.0))

	if has_node("/root/AudioManager"):
		AudioManager.play_music("title", 1.0)

func _show_title() -> void:
	title_panel.visible = true
	slot_select_panel.visible = false
	settings_panel.visible = false

func _on_play_classic_pressed() -> void:
	chosen_campaign_mode = 0
	_open_slot_selection()

func _on_play_sequel_pressed() -> void:
	chosen_campaign_mode = 1
	_open_slot_selection()

func _open_slot_selection() -> void:
	title_panel.visible = false
	slot_select_panel.visible = true
	_refresh_slot_buttons()

func _on_settings_pressed() -> void:
	title_panel.visible = false
	settings_panel.visible = true

func _refresh_slot_buttons() -> void:
	var slots = [slot1_btn, slot2_btn, slot3_btn]
	for i in range(1, 4):
		var btn = slots[i - 1]
		var info = SaveSystem.get_slot_info(i) if has_node("/root/SaveSystem") else {"exists": false}
		if info.get("exists", false):
			btn.text = "Slot %d: Level %d Hero (%d Coins) - %s" % [
				i,
				info.get("level", 1),
				info.get("coins", 0),
				info.get("last_saved", "Saved")
			]
		else:
			btn.text = "Slot %d: [ Empty / New Game ]" % i

func _load_slot(slot_idx: int) -> void:
	var gm = get_node_or_null("/root/GameManager")
	var ss = get_node_or_null("/root/SaveSystem")

	if gm:
		gm.campaign_mode = chosen_campaign_mode
	if ss:
		ss.current_slot = slot_idx
		var info = ss.get_slot_info(slot_idx)
		if info.get("exists", false):
			ss.load_game(slot_idx)
		else:
			ss.new_game(slot_idx)

	# Transition to starting level based on campaign mode
	var target_scene = "res://scenes/original_campaign/cairnwood_forest_part1.tscn"
	if chosen_campaign_mode == 1:
		target_scene = "res://scenes/expansion/sequel_forsaken_expanse.tscn"

	if has_node("/root/SceneTransition"):
		SceneTransition.transition_to_scene(target_scene, "Spawn_Default")
	else:
		get_tree().change_scene_to_file(target_scene)
