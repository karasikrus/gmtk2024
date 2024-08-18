extends Node

signal pre_beat(position)
signal beat(position)
signal measure(position)
signal combo(streak)


@export var pre_bit_interval = 0.1 #(dsmoliakov): how big interval in which we are hitting combo

var combo_streak := 0
var correct_notes := 0

@onready var correct_beat_timer = 0
var accept

func _ready():
	pass
func _physics_process(delta: float) -> void:
	if correct_beat_timer > 0:
		correct_beat_timer -= delta #(iantonov) tick correct_beat_timer

func restart_combo():
	combo_streak = 0
	correct_notes = 0
	

func emit_beat(position):
	beat.emit(position)

func emit_pre_beat(position):
	pre_beat.emit(position)
	correct_beat_timer = pre_bit_interval * 2 #(iantonov) start correct_beat_timer
	

func emit_measure(position):
	measure.emit(position)

func correct_note():
	combo_streak += 1
	correct_notes += 1
	combo.emit(combo_streak)

func wrong_note():
	combo_streak = 0
	combo.emit(combo_streak)

func get_correct_beat_time_left() -> float:
	return correct_beat_timer
