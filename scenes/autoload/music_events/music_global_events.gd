extends Node

signal pre_beat(position)
signal beat(position)
signal measure(position)
signal combo(streak)


@export var pre_bit_interval = 0.1 #(dsmoliakov): how big interval in which we are hitting combo

var combo_streak := 0
var correct_notes := 0

@onready var acceptance_timer = $AcceptanceTimer

func _ready():
	acceptance_timer.one_shot = true
	

func restart_combo():
	combo_streak = 0
	correct_notes = 0
	

func emit_beat(position):
	beat.emit(position)

func emit_pre_beat(position):
	pre_beat.emit(position)
	acceptance_timer.start(pre_bit_interval * 2) #(dsmoliakov): for now symmetrical
	

func emit_measure(position):
	measure.emit(position)

func correct_note():
	combo_streak += 1
	correct_notes += 1
	combo.emit(combo_streak)

func wrong_note():
	combo_streak = 0
	combo.emit(combo_streak)
