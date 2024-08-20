extends Control

func next():
	LevelManager.move_to_next_scene()

func dialog_1():
	DialogPlayer.hide_all()
	DialogPlayer.play_dialog(1, "intro1")

func dialog_2():
	DialogPlayer.hide_all()
	DialogPlayer.play_dialog(1, "intro2")

func dialog_3():
	DialogPlayer.hide_all()
	DialogPlayer.play_dialog(1, "intro3")

func dialog_4():
	DialogPlayer.hide_all()
	DialogPlayer.play_dialog(1, "intro4")
	
