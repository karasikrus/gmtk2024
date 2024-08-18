extends CharacterBody2D
class_name StrongBasicEnemy
@export var max_health = 3
@export var speed = 10

@export var attack_distance = 300 #
@export var min_distance_to_player = 100 #(dsmoliakov): daamn, this thing is resolution dependent
@export var max_distance_to_player = 250
@export var spawn_count = 1

var main_player = null

var is_freezed = false
var is_died = false
var has_armour = true
var is_charging = false
@onready var health = max_health

@export var on_hit_cooldown_time = 0.1
@onready var on_hit_cooldown_timer = $OnHitCooldown

@onready var attack_zone_node = $AttackZone
@onready var attack_zone_area = $AttackZone/AttackZoneArea
@onready var current_health = max_health
var distance_to_player = 1000000
@onready var spawn_points_node = $SpawnPoints

@onready var enemy_to_spawn = load("res://scenes/basic_enemy/basic_enemy.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EnemyManager.add_to_enemy_count(self)
	main_player = get_tree().get_first_node_in_group("player")
	MusicGlobalEvents.beat.connect(_beat_processor)
	pass # Replace with function body.

func _physics_process(delta):
	if is_freezed or is_died or not main_player:
		return
	distance_to_player = (main_player.global_position - global_position).length()
	if not is_charging:
		var direction = main_player.global_position - global_position
		direction = direction.normalized() 
		if distance_to_player > max_distance_to_player:
			direction = direction
		elif distance_to_player < min_distance_to_player:
			direction = -direction
		else:
			#(dsmoliakov): probably worth adding some random direction to make it more dynamic
			pass
			
		velocity = direction * speed
	_process_collision(delta)
	move_and_slide()
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process_collision(delta):
	pass

func _beat_processor(t):
	if _is_in_attack_distance() and not is_charging:
		is_freezed = true
		attack_zone_node.visible = true
		is_charging = true
		return
	
	if is_charging:
		is_charging = false
		attack_zone_node.visible = false
		is_freezed = false
		_check_area_damage()
		return

func _check_area_damage():
	var bodies = attack_zone_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			body.get_hit(1)

func _is_in_attack_distance() -> bool:
	return  distance_to_player < attack_distance

func _process(delta: float) -> void:
	_spawn_enemy()
	pass
	
func destroy_armour():
	has_armour = false
	
func get_hit(direction, is_super_attack, was_on_beat, damage = 1):
	if has_armour and is_super_attack:
		#(dsmoliakov): add effect
		has_armour = false
		return true
	if has_armour:
		return false
	current_health -= damage
	if current_health <= 0:
		_kill()
	return true
		
func _kill():
	is_died = true
	set_collision_mask_value(1, false) #(dsmoliakov): bruh, thats cursed, why it's 1 and not 0
	set_collision_layer_value(1, false)
	EnemyManager.remove_from_enemy_count(self)
	queue_free()
	
func _spawn_enemy():
	if EnemyManager.small_enemy_count == 0:
		var spawn_points = spawn_points_node.get_children()
		spawn_count = min(spawn_count, len(spawn_points))
		for i in range(0, spawn_count):
			var spawn_node_index = randi_range(0, len(spawn_points) - 1)
			var spawn_position = spawn_points[spawn_node_index].global_position
			var enemy = enemy_to_spawn.instantiate()
			enemy.global_position = spawn_position
			get_parent().add_child(enemy)
			pass
