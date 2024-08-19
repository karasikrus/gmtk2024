extends Node

signal pre_beat(position)
signal beat(position)
signal measure(position)
signal combo(streak)
signal size(new_size)
signal big_size(is_big_size)
signal combo_state_changed(combo_state)


@export var pre_bit_interval = 0.17 #(dsmoliakov): how big interval in which we are hitting combo

var combo_streak := 0
var correct_notes := 0

@onready var correct_beat_timer = 0
var accept
var last_size := 0

enum ComboState{
	NO_COMBO,
	SMALL_COMBO,
	BIG_COMBO
}

var current_combo_state := ComboState.NO_COMBO

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
	
func try_emit_size(new_size: int):
	if new_size == last_size:
		return
	size.emit(new_size)
	if new_size > 0 and current_combo_state != ComboState.BIG_COMBO:
		update_combo_state(ComboState.SMALL_COMBO)
	elif new_size == 0:
		update_combo_state(ComboState.NO_COMBO)

func emit_big_size(is_big: bool):
	if is_big:
		update_combo_state(ComboState.BIG_COMBO)
	big_size.emit(is_big)

func update_combo_state(new_state: ComboState):
	if new_state == current_combo_state:
		return
	current_combo_state = new_state
	print("NEW_COMBO_STATE")
	print(current_combo_state)
	combo_state_changed.emit(current_combo_state)
