extends CharacterBody2D
class_name MainCharacter

#(dsmoliakov): common object state
var is_freezed = false
var is_died = false
var is_in_dash = false #(dsmoliakov): also acting as invicibility in get_hit
var is_in_dash_cooldown = false
var is_dash_in_time = false
var is_super_attack = false

@export var speed = 200
@export var projectile_speed = 300

@export var dash_speed_in_time = 500
@export var dash_speed_not_in_time = 400

@export var max_health = 4
@export var dash_cooldown_time = 0.5
@export var dash_duration = 0.2 #(dsmoliakov): smth wrong here tho
@export var max_size = 5
@export var super_attack_time = 0.2

@export var beat_dash_time = 0.1
@export var on_hit_flash_time = 0.5


@onready var dash_cooldown_timer = $DashCooldownTimer
@onready var dash_timer = $DashTimer
@onready var super_attack_timer = $SuperAttackTimer
@onready var on_hit_flash_timer = $OnHitFlashTimer

@onready var projectile = load("res://scenes/projectile/projectile.tscn")
@onready var wavefront = load("res://scenes/explosion/explosion.tscn")

@onready var sprite = $Sprite2D as Sprite2D


var last_direction = null
var current_size = 0

var sizes = [1, 1.5, 2, 2.5, 3, 3.5]

func _ready():
	dash_timer.one_shot = true
	dash_cooldown_timer.one_shot = true
	on_hit_flash_timer.one_shot = true

func _process(delta):
	if on_hit_flash_timer.time_left > 0:
		var normalized_time = on_hit_flash_timer.time_left / on_hit_flash_time
		sprite.material.set_shader_parameter("normalized_time", normalized_time as float)

func _physics_process(delta):
	if is_freezed or is_died:
		return
	
	_process_WASD_input(delta)
	_process_dash(delta)
	_process_collision(delta)
	_process_super_attack(delta)
	
	move_and_slide()


func _process_WASD_input(delta):
	if is_in_dash or is_super_attack:
		return
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction != Vector2(0.0, 0.0):
		last_direction = direction
	velocity = direction * speed


func _process_dash(delta):
	if is_in_dash or is_in_dash_cooldown or is_super_attack:
		return
	var is_dash_pressed = Input.is_action_pressed("dash")
	if not is_dash_pressed:
		return
		
	var dash_speed = 0 
	var acceptance_time_left = MusicGlobalEvents.get_correct_beat_time_left()
	if acceptance_time_left > 0:
		dash_speed = dash_speed_in_time
		is_dash_in_time = true
		prints("dash in time")
	else:
		dash_speed = dash_speed_not_in_time
		prints("dash not in time")
	var dash_time_offset = acceptance_time_left - MusicGlobalEvents.pre_bit_interval #(dsmoliakov): we might to adapt this to non symmetric interval
	velocity = last_direction * dash_speed
	dash_timer.start(dash_cooldown_time + dash_time_offset)
	is_in_dash = true
	
func _process_super_attack(delta):
	if is_in_dash or is_in_dash_cooldown or is_super_attack: #(dsmoliakov) is it right tho?
		return
	if current_size == 0:
		return
	var is_super_attack_pressed = Input.is_action_pressed("super_attack")
	if not is_super_attack_pressed:
		return
	var projectile_node = projectile.instantiate() as Projectile
	projectile_node.position = position
	projectile_node.direction = last_direction
	projectile_node.velocity = projectile_speed
	projectile_node.size = current_size
	projectile_node.was_on_beat = is_dash_in_time
	get_parent().add_child(projectile_node)
	
	var wavefront_node = wavefront.instantiate() as Explosion
	wavefront_node.position = position
	wavefront_node.radius = 10
	wavefront_node.starting_radius = 0
	wavefront_node.time = 1
	wavefront_node.was_on_beat = is_dash_in_time
	get_parent().add_child(wavefront_node)
	
	is_super_attack = true
	super_attack_timer.start(super_attack_time)
	drop_size()	
	pass


func _process_collision(delta):
	var collision = move_and_collide(velocity * delta, true)
	
	if not collision:
		return
	var collider = collision.get_collider()

	if collider.is_in_group("enemy") or collider.is_in_group("StrongBasicEnemy") and is_in_dash:
		if is_dash_in_time:
			var success = collider.get_hit(last_direction, false, is_dash_in_time)
			if success:
				increase_size(1)
			var enemy_died = collider.is_died
			if not enemy_died:
				last_direction = -last_direction
				velocity = last_direction * dash_speed_in_time
		else:
			var normal = collision.get_normal()
			var reflected_direction = normal.reflect(last_direction)
			velocity = -last_direction * speed

	if collider.is_in_group("breakable_wall"):
		if is_dash_in_time:
			collider.destroy_wall()
		else:
			last_direction = -last_direction
			velocity = last_direction * dash_speed_in_time
			
	if collider.is_in_group("spike"):
		last_direction = -last_direction
		velocity = last_direction * dash_speed_in_time
		get_hit(1, true)

func get_hit(damage = 1, force_give_hit = false):
	if (is_in_dash or is_super_attack) and !force_give_hit:
		return
		
	if current_size == 0:
		is_died = true
		LevelManager.reload_scene()
	else:
		on_hit_flash_timer.start(on_hit_flash_time)
		drop_size()

func _on_dash_timer_timeout() -> void:
	is_in_dash = false
	is_in_dash_cooldown = true
	is_dash_in_time = false
	velocity = last_direction * speed
	dash_cooldown_timer.start(dash_cooldown_time)

func increase_size(value = 1):
	current_size = clampi(value + 1, 0, max_size)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(sizes[current_size], sizes[current_size]), 0.1)

func drop_size():
	current_size = 0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(sizes[current_size], sizes[current_size]), 0.1)

func _on_dash_cooldown_timer_timeout() -> void:
	is_in_dash_cooldown = false

func can_super_attack() -> bool:
	return current_size > 0

func _on_super_attack_timer_timeout() -> void:
	is_super_attack = false
	pass # Replace with function body.

func get_current_size() -> int:
	return current_size
