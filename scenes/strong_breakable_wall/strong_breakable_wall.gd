extends StaticBody2D
class_name StrongBreakableWall

@onready var spawn_points_node = $SpawnPoints
@onready var player
@export var spawn_count = 1
@onready var enemy_to_spawn = load("res://scenes/basic_enemy/basic_enemy.tscn")
@onready var spawn_zone = $SpawnZone
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as MainCharacter
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if EnemyManager.enemy_count != 0:
		return
	var bodies = spawn_zone.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			_spawn_enemy()


func _spawn_enemy():
	if EnemyManager.enemy_count == 0 and player.get_current_size() == 0:
		var spawn_points = spawn_points_node.get_children()
		spawn_count = min(spawn_count, len(spawn_points))
		for i in range(0, spawn_count):
			var spawn_node_index = randi_range(0, len(spawn_points) - 1)
			var spawn_position = spawn_points[spawn_node_index].global_position
			var enemy = enemy_to_spawn.instantiate()
			enemy.global_position = spawn_position
			get_parent().add_child(enemy)
			pass

func destroy_wall():
	set_collision_mask_value(1, false) #(dsmoliakov): bruh, thats cursed, why it's 1 and not 0
	set_collision_layer_value(1, false)
	queue_free()


func _on_spawn_zone_body_entered(body: Node2D) -> void:
	_spawn_enemy()
	pass # Replace with function body.
