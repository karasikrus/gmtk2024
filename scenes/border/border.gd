extends CanvasLayer
class_name Border

@onready var texture_rect: TextureRect = %TextureRect

@export var beat_scale:= Vector2(0.95, 0.95)

var beat_tween : Tween


func _ready() -> void:
	MusicGlobalEvents.beat.connect(anim_beat)



func anim_beat(_position):
	print("border_beat")
	if beat_tween:
		beat_tween.kill()
	beat_tween = get_tree().create_tween()
	beat_tween.tween_property(texture_rect, "scale", beat_scale, 0.1)
	beat_tween.tween_property(texture_rect, "scale", Vector2.ONE, 0.3)

func update_state():
	pass
