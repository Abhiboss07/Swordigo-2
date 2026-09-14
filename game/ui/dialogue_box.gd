extends PanelContainer

## DialogueBox UI Component (ShowTextBubbles)
## Displays NPC dialogues, lore descriptions, and narrative instructions.

signal dialogue_finished

@onready var speaker_label: Label = $MarginContainer/VBoxContainer/SpeakerLabel
@onready var text_label: RichTextLabel = $MarginContainer/VBoxContainer/TextLabel
@onready var prompt_label: Label = $MarginContainer/VBoxContainer/PromptLabel

var current_lines: Array[String] = []
var line_index: int = 0
var is_active: bool = false

func _ready() -> void:
	visible = false

func display_dialogue(speaker: String, lines: Array[String]) -> void:
	if lines.is_empty():
		return
	speaker_label.text = speaker
	current_lines = lines
	line_index = 0
	is_active = true
	visible = true
	_show_current_line()

func _input(event: InputEvent) -> void:
	if not is_active:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("jump") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		_advance_line()
		get_viewport().set_input_as_handled()

func _show_current_line() -> void:
	if line_index < current_lines.size():
		text_label.text = current_lines[line_index]
	else:
		_close_dialogue()

func _advance_line() -> void:
	line_index += 1
	if line_index < current_lines.size():
		_show_current_line()
	else:
		_close_dialogue()

func _close_dialogue() -> void:
	is_active = false
	visible = false
	dialogue_finished.emit()
