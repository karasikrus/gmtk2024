extends Node


@onready var current_scene = "res://scenes/menu/main_menu.tscn" 
@onready var current_scene_index = 0

var scene_list = [
	"res://scenes/menu/main_menu.tscn",
	"res://scenes/test/test_basic_enemy/intro.tscn",
	"res://scenes/test/test_basic_enemy/door_level.tscn",
	"res://scenes/test/test_basic_enemy/test_basic_enemy.tscn",
	"res://scenes/test/test_basic_enemy/hard_door_level.tscn",
	"res://scenes/test/test_basic_enemy/big.tscn",
	"res://scenes/test/test_basic_enemy/boss_level.tscn",
	"res://scenes/test/test_basic_enemy/Final.tscn"
]

func reload_scene():
	DialogPlayer.hide_all()
	get_tree().change_scene_to_file(scene_list[current_scene_index])

func move_to_next_scene():
	DialogPlayer.hide_all()
	current_scene_index += 1
	get_tree().change_scene_to_file(scene_list[current_scene_index])
