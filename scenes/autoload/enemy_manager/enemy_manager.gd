extends Node2D

@onready var enemy_count = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_to_enemy_count(enemy):
	enemy_count += 1
	
func remove_from_enemy_count(enemy):
	enemy_count -= 1
	
func get_enemy_count() -> int:
	return enemy_count
