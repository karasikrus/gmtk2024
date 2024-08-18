extends CharacterBody2D

@export var max_health = 3
@export var speed = 10
@export var on_hit_speed = 100
@export var attack_distance = 300 #
@export var min_distance_to_player = 100 #(dsmoliakov): daamn, this thing is resolution dependent
@export var max_distance_to_player = 250
@export var projectile_velocity = 50
var distance_to_player = 1000000
var main_player = null

var is_freezed = false
var is_died = false
var is_charging = false

@onready var projectile =  load("res://scenes/long_range_enemy/projectile/long_range_enemy_projectile.tscn")
@onready var health = max_health
@onready var line = $Line2D as Line2D

func _ready() -> void:
	EnemyManager.add_to_enemy_count(self)
	main_player = get_tree().get_first_node_in_group("player")
	MusicGlobalEvents.beat.connect(_beat_processor)
	pass # Replace with function body.


func _process(delta: float) -> void:
	if is_charging:
		line.clear_points()
		line.add_point(to_local(main_player.global_position))
		
		line.add_point(to_local(global_position))
	elif line.get_point_count() != 0:
		line.clear_points()

func _physics_process(delta: float) -> void:
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
	move_and_slide()

func _is_in_attack_distance() -> bool:
	return  distance_to_player < attack_distance

func _beat_processor(t):
	if _is_in_attack_distance() and not is_charging:
		is_freezed = true
		is_charging = true
		return
	
	if is_charging:
		is_charging = false
		is_freezed = false
		var direction_to_player = (main_player.global_position - global_position).normalized()
		var projectile_node = projectile.instantiate()
		projectile_node.global_position = global_position + direction_to_player * 10 #(dsmoliakov): move to export constants
		projectile_node.velocity = projectile_velocity * 2
		projectile_node.direction = direction_to_player
		get_parent().add_child(projectile_node)
		return
		
		
func kill():
	#(dsmoliakov): probably do animation
	is_died = true
	set_collision_mask_value(1, false) #(dsmoliakov): bruh, thats cursed, why it's 1 and not 0
	set_collision_layer_value(1, false)
	EnemyManager.remove_from_enemy_count(self)
	queue_free()
	
func get_hit(direction, was_super_attack, was_on_beat, damage = 1):
	if is_died:
		return false
	velocity = direction * on_hit_speed
	health -= damage
	if health <= 0:
		kill()
	return true
	
