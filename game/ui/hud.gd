extends Control

const SwordigoTheme = preload("res://systems/swordigo_theme.gd")

## HUD Controller (Authentic 2012 Swordigo Mobile On-Screen Display)
## Manages health hearts, mana crystals, coin count, level/XP bar,
## active spell display, boss health meter, touch controls, and pause button.

# Top Left: Health, Mana, Level
@onready var hearts_container: HBoxContainer = $TopLeft/HeartsContainer
@onready var mana_bar: ProgressBar = $TopLeft/ManaBar
@onready var level_label: Label = $TopLeft/LevelLabel
@onready var xp_bar: ProgressBar = $TopLeft/XpBar

# Top Right: Shards, Coins, Menu
@onready var coins_label: Label = $TopRight/CoinsHBox/CoinsLabel
@onready var shards_container: HBoxContainer = $TopRight/ShardsContainer
@onready var menu_btn: Button = $TopRight/MenuBtn

# Center Top: Boss Health Bar
@onready var boss_container: VBoxContainer = $TopCenter/BossContainer
@onready var boss_name_label: Label = $TopCenter/BossContainer/BossName
@onready var boss_health_bar: ProgressBar = $TopCenter/BossContainer/BossHealthBar

# Touch Controls (Mobile Virtual Pad)
@onready var touch_controls: Control = $TouchControls
@onready var btn_left: Button = $TouchControls/Dpad/BtnLeft
@onready var btn_right: Button = $TouchControls/Dpad/BtnRight
@onready var btn_jump: Button = $TouchControls/Actions/BtnJump
@onready var btn_attack: Button = $TouchControls/Actions/BtnAttack
@onready var btn_spell: Button = $TouchControls/Actions/BtnSpell

# Floating InGameHub instance
@onready var in_game_hub: Control = $InGameHub

var current_hearts: Array[TextureRect] = []
var max_hp_cached: int = 5
var current_hp_cached: int = 5

func _ready() -> void:
	if boss_container:
		boss_container.visible = false

	# Connect GameManager signals
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.player_health_changed.connect(_on_health_changed)
		gm.player_mana_changed.connect(_on_mana_changed)
		gm.coins_changed.connect(_on_coins_changed)
		gm.boss_health_changed.connect(_on_boss_health_changed)
		gm.boss_defeated.connect(_on_boss_defeated)

	var inv = get_node_or_null("/root/Inventory")
	if inv:
		inv.level_up.connect(_on_level_up)
		inv.item_added.connect(_on_inventory_updated)

	if menu_btn:
		menu_btn.pressed.connect(_on_menu_pressed)

	_setup_touch_controls()
	_refresh_all()

func _refresh_all() -> void:
	var gm = get_node_or_null("/root/GameManager")
	var inv = get_node_or_null("/root/Inventory")

	if inv:
		_on_coins_changed(inv.coins)
		_refresh_level_and_xp()
		_refresh_shards()

	if gm and gm.player and is_instance_valid(gm.player):
		_on_health_changed(gm.player.current_health, gm.player.max_health)
		_on_mana_changed(gm.player.current_mana, gm.player.max_mana)
	elif inv:
		_on_health_changed(inv.get_total_max_health(), inv.get_total_max_health())
		_on_mana_changed(inv.get_total_max_mana(), inv.get_total_max_mana())

func _on_health_changed(cur_hp: int, max_hp: int) -> void:
	current_hp_cached = cur_hp
	max_hp_cached = max_hp

	# Rebuild hearts container
	for child in hearts_container.get_children():
		child.queue_free()

	for i in range(max_hp):
		var heart = ColorRect.new()
		heart.custom_minimum_size = Vector2(22, 22)
		if i < cur_hp:
			heart.color = SwordigoTheme.COLOR_HEART_RED
		else:
			heart.color = Color(0.25, 0.08, 0.08, 0.7)
		hearts_container.add_child(heart)

func _on_mana_changed(cur_mana: int, max_mana: int) -> void:
	if mana_bar:
		mana_bar.max_value = max_mana
		mana_bar.value = cur_mana

func _on_coins_changed(coins: int) -> void:
	if coins_label:
		coins_label.text = "%d" % coins

func _refresh_level_and_xp() -> void:
	var inv = get_node_or_null("/root/Inventory")
	if not inv:
		return
	if level_label:
		level_label.text = "Lv. %d" % inv.level
	if xp_bar:
		xp_bar.max_value = inv.xp_to_next
		xp_bar.value = inv.xp

func _refresh_shards() -> void:
	var inv = get_node_or_null("/root/Inventory")
	if not inv or not shards_container:
		return

	for child in shards_container.get_children():
		child.queue_free()

	for i in range(4):
		var shard_id = "iselon_shard_%d" % (i + 1)
		var shard_rect = ColorRect.new()
		shard_rect.custom_minimum_size = Vector2(16, 16)
		if inv.has_item(shard_id):
			shard_rect.color = SwordigoTheme.COLOR_SHARD_CYAN
		else:
			shard_rect.color = Color(0.2, 0.2, 0.25, 0.5)
		shards_container.add_child(shard_rect)

func _on_level_up(_new_level: int) -> void:
	_refresh_level_and_xp()
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.player and is_instance_valid(gm.player):
		_on_health_changed(gm.player.current_health, gm.player.max_health)
		_on_mana_changed(gm.player.current_mana, gm.player.max_mana)

func _on_inventory_updated(_id: String, _count: int) -> void:
	_refresh_shards()

func _on_boss_health_changed(boss_name: String, cur_hp: int, max_hp: int) -> void:
	if not boss_container:
		return
	boss_container.visible = true
	boss_name_label.text = boss_name
	boss_health_bar.max_value = max_hp
	boss_health_bar.value = cur_hp

func _on_boss_defeated(_boss_name: String) -> void:
	if boss_container:
		var tween = create_tween()
		tween.tween_property(boss_container, "modulate:a", 0.0, 1.0)
		await tween.finished
		boss_container.visible = false
		boss_container.modulate.a = 1.0

func _on_menu_pressed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if in_game_hub:
		if in_game_hub.visible:
			in_game_hub.close_hub()
		else:
			in_game_hub.visible = true
			if gm:
				gm.set_pause(true)

func _setup_touch_controls() -> void:
	# Virtual Touch / Mouse buttons for mobile / touch play
	if btn_left:
		btn_left.button_down.connect(func(): Input.action_press("move_left"))
		btn_left.button_up.connect(func(): Input.action_release("move_left"))
	if btn_right:
		btn_right.button_down.connect(func(): Input.action_press("move_right"))
		btn_right.button_up.connect(func(): Input.action_release("move_right"))
	if btn_jump:
		btn_jump.button_down.connect(func(): Input.action_press("jump"))
		btn_jump.button_up.connect(func(): Input.action_release("jump"))
	if btn_attack:
		btn_attack.button_down.connect(func(): Input.action_press("attack"))
		btn_attack.button_up.connect(func(): Input.action_release("attack"))
	if btn_spell:
		btn_spell.button_down.connect(func(): Input.action_press("spell"))
		btn_spell.button_up.connect(func(): Input.action_release("spell"))
