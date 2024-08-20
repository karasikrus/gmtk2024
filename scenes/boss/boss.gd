extends StaticBody2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var timer: Timer = $"../Timer"

enum {FIRST_STAGE, SECOND_STAGE, LAST_STAGE}
var armour_count = 1
var stage = FIRST_STAGE
var second_stage_projectile_index = 0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var count_of_projectiles_on_first_stage = 3
@export var projectile_velocity = 150
@export var direction_offset = 1
@export var spawn_count = 3

@export var second_stage_player_needed_size = 3

@onready var projectile = load("res://scenes/boss/first_stage_projectile/projectile.tscn")
@onready var projectile_second_stage = load("res://scenes/boss/second_stage_projectile/projectile.tscn")
@onready var enemy_to_spawn = load("res://scenes/basic_enemy/basic_enemy.tscn")
@onready var spawn_points_node = $SpawnPoints
@onready var spawn_points_node_second_stage = $SpawnPointsSecondStage
@onready var projectile_timer = $ProjectileTimer
@onready var projectile_spawn_points_node_second_stage = $SecondStageProjectilSpawnPoints

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D



func _ready() -> void:
	MusicGlobalEvents.beat.connect(fire_projectile_on_beat)



	
func fire_projectiles_on_first_stage():
	if stage != FIRST_STAGE:
		return
	var direction_to_player = (player.position - position).normalized()
	for i in range(0, count_of_projectiles_on_first_stage):
		var direction = direction_to_player.rotated(randf_range(-direction_offset, direction_offset))
		var projectile_node = projectile.instantiate()
		projectile_node.direction = direction
		projectile_node.velocity = projectile_velocity
		projectile_node.position = position
		get_parent().add_child(projectile_node)
		

func spawn_enemies_on_first_stage():
	if stage != FIRST_STAGE:
		return
	if EnemyManager.small_enemy_count == 0:
		var spawn_points = spawn_points_node.get_children()
		spawn_count = 1
		for i in range(0, spawn_count):
			var spawn_node_index = randi_range(0, len(spawn_points) - 1)
			var spawn_position = spawn_points[spawn_node_index].global_position
			var enemy = enemy_to_spawn.instantiate()
			enemy.global_position = spawn_position
			get_parent().add_child(enemy)
			pass
			
func spawn_enemies_on_second_stage():
	if !(stage == SECOND_STAGE or stage == LAST_STAGE):
		return
	print("enemies")
	if EnemyManager.small_enemy_count < 6:
		var spawn_points = spawn_points_node_second_stage.get_children()
		spawn_count = 1
		for i in range(0, spawn_count):
			var spawn_node_index = randi_range(0, len(spawn_points) - 1)
			var spawn_position = spawn_points[spawn_node_index].global_position
			var enemy = enemy_to_spawn.instantiate()
			enemy.global_position = spawn_position
			enemy.speed = 0
			enemy.speed_on_dash = 0
			get_parent().add_child(enemy)
			pass


func fire_projectiles_on_second_stage():
	if stage != SECOND_STAGE:
		return
	var projectile_node = projectile_second_stage.instantiate()
	projectile_node.direction = Vector2(0, 1)
	projectile_node.velocity = projectile_velocity * 2
	var spawn_nodes = projectile_spawn_points_node_second_stage.get_children()
	projectile_node.global_position = spawn_nodes[second_stage_projectile_index].global_position
	second_stage_projectile_index ^= 1
	get_parent().add_child(projectile_node)

		
var hp = 5
func get_hit(is_super_attack, was_on_beat, damage = 1):
	if armour_count and is_super_attack and was_on_beat and stage == FIRST_STAGE:
		#(dsmoliakov): add effect
		armour_count = false
		stage = SECOND_STAGE
		timer.start()
		timer.timeout.connect(_kill)
		animation_player.play("large")
		return true
	if stage == SECOND_STAGE:
		hp-=1
		if hp <= 0:
			_kill()
	return false
		
func _kill():
	LevelManager.move_to_next_scene()
	queue_free()
	
	
func _physics_process(delta: float) -> void:
	pass

func _process(delta: float) -> void:
	spawn_enemies_on_first_stage()
	spawn_enemies_on_second_stage()

func fire_projectile_on_beat(t):
	fire_projectiles_on_first_stage()
	fire_projectiles_on_second_stage()
	pass # Replace with function body.

func process_player_size_increase(size):
	if stage != SECOND_STAGE:
		return
		
	if size >= second_stage_player_needed_size:
		stage = LAST_STAGE
		player.is_invincible = true
		animation_player.play("large_weak")
