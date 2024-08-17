extends Node

signal pre_beat(position)
signal beat(position)
signal measure(position)
signal combo(streak)


@export var pre_bit_interval = 0.1 #(dsmoliakov): how big interval in which we are hitting combo

var combo_streak := 0
var total_notes := 0
var correct_notes := 0


func restart_combo():
	combo_streak = 0
	total_notes = 0
	correct_notes = 0


func emit_beat(position):
	beat.emit(position)

func emit_pre_beat(position):
	pre_beat.emit(position)

func emit_measure(position):
	measure.emit(position)

func correct_note():
	combo_streak += 1
	total_notes += 1
	correct_notes += 1
	combo.emit(combo_streak)

func wrong_note():
	combo_streak = 0
	total_notes += 1
	combo.emit(combo_streak)
