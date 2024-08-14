extends CanvasLayer
class_name OptionsMenu

signal back_pressed

@onready var sfx_slider = %SfxSlider
@onready var music_slider = %MusicSlider
@onready var window_mode_button = %WindowModeButton
@onready var back_button = %BackButton
@onready var audio_stream_player = $AudioStreamPlayer


func _ready():
	back_button.pressed.connect(on_back_pressed)
	window_mode_button.pressed.connect(on_window_mode_button_pressed)
	sfx_slider.value_changed.connect(on_audio_slider_changed.bind("sfx"))
	music_slider.value_changed.connect(on_audio_slider_changed.bind("music"))
	sfx_slider.drag_ended.connect(on_sfx_drag_ended)
	update_display()


func get_bus_volume_percent(bus_name: String) -> float:
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)


func set_bus_volume_percent(bus_name: String, percent: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = linear_to_db(percent)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


func on_window_mode_button_pressed():
	var mode = DisplayServer.window_get_mode()
	if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	update_display()


func update_display():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		window_mode_button.text = "Fullscreen"
	else:
		window_mode_button.text = "Windowed"
	sfx_slider.value = get_bus_volume_percent("sfx")
	music_slider.value = get_bus_volume_percent("music")


func on_audio_slider_changed(value: float, bus_name: String):
	set_bus_volume_percent(bus_name, value)
	
	
func on_sfx_drag_ended(value_changed: bool):
	audio_stream_player.play()


func on_back_pressed():
	SceneTransition.close_screen()
	await SceneTransition.transition_halfway
	back_pressed.emit()
	SceneTransition.open_screen()
