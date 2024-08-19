extends CanvasLayer
class_name Border

@onready var texture_rect: TextureRect = %TextureRect
@onready var texture_rect_better: TextureRect = %TextureRectBetter
@onready var texture_rect_full: TextureRect = %TextureRectFull
@onready var texture_rect_sad: TextureRect = %TextureRectSad

@onready var texture_rect_fixed: TextureRect = %TextureRectFixed
@onready var texture_rect_fixed_better: TextureRect = %TextureRectFixedBetter
@onready var texture_rect_fixed_full: TextureRect = %TextureRectFixedFull
@onready var texture_rect_fixed_sad: TextureRect = %TextureRectFixedSad


@onready var beat_rects: Control = %Beat
@onready var fixed_rects: Control = %Fixed

@export var beat_scale:= Vector2(0.95, 0.95)

var beat_tween : Tween
var change_state_tween : Tween

var change_state_speed := 0.2



enum BorderState{
	DEFAULT,
	BETTER,
	FULL,
	SAD
}
var current_state := BorderState.SAD

func _ready() -> void:
	MusicGlobalEvents.beat.connect(anim_beat)
	MusicGlobalEvents.combo_state_changed.connect(on_combo_state_changed)
	update_state(BorderState.DEFAULT)



func anim_beat(_position):
	print("border_beat")
	if beat_tween:
		beat_tween.kill()
	beat_tween = get_tree().create_tween()
	beat_tween.tween_property(beat_rects, "scale", beat_scale, 0.1)
	beat_tween.tween_property(beat_rects, "scale", Vector2.ONE, 0.3)

func on_full_size(is_full):
	if is_full:
		update_state(BorderState.FULL)


func on_combo_state_changed(combo_state):
	if combo_state == MusicGlobalEvents.ComboState.NO_COMBO:
		update_state(BorderState.DEFAULT)
	if combo_state == MusicGlobalEvents.ComboState.SMALL_COMBO:
		update_state(BorderState.BETTER)
	if combo_state == MusicGlobalEvents.ComboState.BIG_COMBO:
		update_state(BorderState.FULL)

func update_state(new_state: BorderState):
	if current_state == new_state:
		return
	print("NEW_BORDER_STATE")
	print(new_state)
	current_state = new_state
	if change_state_tween:
		change_state_tween.kill()
	change_state_tween = get_tree().create_tween()
	change_state_tween.set_parallel()
	
	if current_state == BorderState.DEFAULT:
		change_state_tween.tween_property(texture_rect_better, "modulate:a", 0, change_state_speed)
		change_state_tween.tween_property(texture_rect_full, "modulate:a", 0, change_state_speed)
		change_state_tween.tween_property(texture_rect_fixed_better, "modulate:a", 0, change_state_speed)
		change_state_tween.tween_property(texture_rect_fixed_full, "modulate:a", 0, change_state_speed)
	if current_state == BorderState.BETTER:
		change_state_tween.tween_property(texture_rect_better, "modulate:a", 1, change_state_speed)
		change_state_tween.tween_property(texture_rect_full, "modulate:a", 0, change_state_speed)
		change_state_tween.tween_property(texture_rect_fixed_better, "modulate:a", 1, change_state_speed)
		change_state_tween.tween_property(texture_rect_fixed_full, "modulate:a", 0, change_state_speed)
	if current_state == BorderState.FULL:
		change_state_tween.tween_property(texture_rect_full, "modulate:a", 1, change_state_speed)
		change_state_tween.tween_property(texture_rect_fixed_full, "modulate:a", 1, change_state_speed)
	
		
