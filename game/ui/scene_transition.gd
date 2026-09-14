extends CanvasLayer

## SceneTransition Autoload (Game.FadeIn / Game.FadeOut)
## Manages seamless screen-fade transitions and player placement at named spawn markers.

signal transition_started
signal transition_finished

@onready var color_rect: ColorRect = $ColorRect

var target_spawn_marker: String = "Spawn_Default"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.color = Color(0, 0, 0, 0)

func transition_to_scene(scene_path: String, spawn_marker: String = "Spawn_Default") -> void:
	target_spawn_marker = spawn_marker
	transition_started.emit()

	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished

	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame

	_place_player_at_marker()

	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(color_rect, "color:a", 0.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await fade_in_tween.finished

	transition_finished.emit()

func _place_player_at_marker() -> void:
	var gm = get_node_or_null("/root/GameManager")
	var player = gm.player if (gm and is_instance_valid(gm.player)) else null
	if not player:
		player = get_tree().get_first_node_in_group("Player")

	if player:
		var marker: Node3D = null
		if target_spawn_marker != "":
			marker = get_tree().current_scene.find_child(target_spawn_marker, true, false)

		if marker:
			player.global_position = marker.global_position
			player.position.z = 0.0
			player.velocity = Vector3.ZERO
		else:
			var default_marker = get_tree().current_scene.find_child("Spawn_Default", true, false)
			if default_marker:
				player.global_position = default_marker.global_position
				player.position.z = 0.0
				player.velocity = Vector3.ZERO
