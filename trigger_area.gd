extends Area2D
class_name TriggerArea

@export_category("Load next level")
@export var load_next_level := false

@export_category("Start dialog")
@export var dialog_icon_int := 2
@export var dialog_timeline_name := "enemy1"


func _on_body_entered(body: Node2D) -> void:
	if load_next_level:
		LevelManager.move_to_next_scene()
	else:
		DialogPlayer.play_dialog(dialog_icon_int, dialog_timeline_name)
