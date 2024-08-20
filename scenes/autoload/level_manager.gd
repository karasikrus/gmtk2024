extends Node


@onready var current_scene = "res://scenes/menu/main_menu.tscn" 
@onready var current_scene_index = 0

var scene_list = [
	"res://scenes/menu/main_menu.tscn",
	"res://scenes/test/test_basic_enemy/test_hard_enemy.tscn" 
]

func reload_scene():
	get_tree().change_scene_to_file(scene_list[current_scene_index])

func move_to_next_scene():
	current_scene_index += 1
	get_tree().change_scene_to_file(scene_list[current_scene_index])
