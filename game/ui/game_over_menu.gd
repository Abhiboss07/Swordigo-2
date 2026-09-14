extends Control

## GameOverMenu Controller
## Appears upon player defeat; provides options to respawn at active checkpoint or return to title.

@onready var respawn_btn: Button = $Panel/VBox/RespawnBtn
@onready var title_btn: Button = $Panel/VBox/TitleBtn

func _ready() -> void:
	visible = false
	if respawn_btn:
		respawn_btn.pressed.connect(_on_respawn_pressed)
	if title_btn:
		title_btn.pressed.connect(_on_title_pressed)

func _on_respawn_pressed() -> void:
	visible = false
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.respawn_player()

func _on_title_pressed() -> void:
	visible = false
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.reset_session()
	if has_node("/root/SceneTransition"):
		get_node("/root/SceneTransition").transition_to_scene("res://ui/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
