extends Control

func next():
	LevelManager.move_to_next_scene()

func dialog_1():
	DialogPlayer.hide_all()
	#DialogPlayer.play_dialog()
