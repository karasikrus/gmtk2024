extends Node2D

var timelines_to_play = []

var is_playing_right_now = false
@export var timeline_autoskip_time = 0.4
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.timeline_ended.connect(func():is_playing_right_now = false)
	Dialogic.timeline_ended.connect(func():animation_player.play("noone"))
	MusicGlobalEvents.beat.connect(play_on_beat)
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass
	if Input.is_action_just_pressed("debug"):
		play_dialog(2, "enemy1")

func play_dialog(picture_type, dialog):
	Dialogic.start(dialog)
	if picture_type == 1:
		animation_player.play("vamp")
	elif picture_type == 2:
		animation_player.play("boss")
	
func hide_all():
	Dialogic.end_timeline()
	animation_player.play("noone")

func add_to_play(timeline):
	timelines_to_play.append(timeline)

func play_on_beat():
	if len(timelines_to_play) == 0 or is_playing_right_now:
		return
	Dialogic.play(timelines_to_play[0])
	Dialogic.Inputs.auto_skip = timeline_autoskip_time
	timelines_to_play.remove_at(0)
	is_playing_right_now = true
