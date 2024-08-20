extends AudioStreamPlayer
class_name MusicController
@export var bpm := 80	
@export var measures := 4
@export var beat_in_measure := 4
var next_note_index := 0

var song_position := 0.0
var song_position_in_beats = 1
var sec_per_beat : float
var last_reported_beat = 0
var measure = 1
var pre_beat_passed = false

@export var music_change_time = 1
@onready var timer = $MuteOutTimer

func _ready():
	sec_per_beat = 60.0 / bpm
	MusicGlobalEvents.beat.connect(on_beat)
	MusicGlobalEvents.restart_combo()
	MusicGlobalEvents.combo.connect(combo_check)
# Called when the node enters the scene tree for the first time.

func _physics_process(delta):
	if playing:
		var prev_song_position = song_position
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency()
		song_position_in_beats = int(floor(song_position / sec_per_beat))
		if (prev_song_position > song_position):
			last_reported_beat = 0
		update_pre_beat()
		update_beat()

func update_pre_beat():
	if pre_beat_passed:
		return
	if song_position_in_beats % measures != (beat_in_measure - 1) % measures:
			return
	var song_position_of_next_beat = (song_position_in_beats + 1) * sec_per_beat
	if	(song_position + MusicGlobalEvents.pre_bit_interval) >= song_position_of_next_beat:
		MusicGlobalEvents.emit_pre_beat(song_position_in_beats + 1)
		prints("pre beat", song_position_in_beats, "measure", measure)
		pre_beat_passed = true
		
		
func update_beat():	
	if last_reported_beat >= song_position_in_beats:
		return
	if song_position_in_beats % measures != beat_in_measure % measures:
		return
	if measure > measures:
		measure = 1
	MusicGlobalEvents.emit_beat(song_position_in_beats)
	MusicGlobalEvents.emit_measure(measure)
	last_reported_beat = song_position_in_beats
	prints("beat", last_reported_beat, "measure", measure)
	pre_beat_passed = false
	measure += 1



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func on_beat(beat_number : int):
	pass

func combo_check(combo_num):
	pass

	
