extends Node2D

var timelines_to_play = []

var is_playing_right_now = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.timeline_ended.connect(func():is_playing_right_now = false)
	MusicGlobalEvents.beat.connect(play_on_beat)
	pass # Replace with function body.

func add_to_play(timeline):
	timelines_to_play.append(timeline)

func play_on_beat():
	if len(timelines_to_play) == 0 or is_playing_right_now:
		return
	Dialogic.play(timelines_to_play[0])
	timelines_to_play.remove_at(0)
	is_playing_right_now = true

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
