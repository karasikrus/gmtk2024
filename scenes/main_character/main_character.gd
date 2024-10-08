extends CharacterBody2D
class_name MainCharacter

#(dsmoliakov): common object state
var is_freezed = false
var is_died = false
var is_in_dash = false #(dsmoliakov): also acting as invicibility in get_hit
var is_in_dash_cooldown = false
var is_dash_in_time = false
var is_super_attack = false
var is_invincible = false

@export var super_attack_threshold := 3

signal increased_size_signal(size)

#region Anim vars

var is_anim_walking := false
var is_anim_in_good_dash := false
var is_anim_in_bad_dash := false
var is_anim_talking_hit := false
var is_anim_special_attack := false

#endregion

@export var speed = 200
@export var projectile_speed = 300

@export var dash_speed_in_time = 500
@export var dash_speed_not_in_time = 400

@export var max_health = 4
@export var dash_cooldown_time = 0.5
@export var dash_duration = 0.2 #(dsmoliakov): smth wrong here tho
@export var max_size = 5
@export var super_attack_time = 0.2

@export var on_hit_flash_time = 0.5
@export var ghosts_count_dash_in_time = 3
@export var ghosts_count_dash_not_in_time = 1
@export var ghosts_delay = 0.05

@onready var dash_cooldown_timer = $DashCooldownTimer
@onready var dash_timer = $DashTimer
@onready var super_attack_timer = $SuperAttackTimer
@onready var on_hit_flash_timer = $OnHitFlashTimer
@onready var ghost_timer = $GhostTimer

@onready var projectile = load("res://scenes/projectile/projectile.tscn")
@onready var wavefront = load("res://scenes/explosion/explosion.tscn")

@onready var ghost = load("res://scenes/main_character/player_ghost.tscn")

@onready var sprite = $Sprite2D as Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


#particles

@export var particle_count_on_success = 6
@export var particle_count_on_failure = 1
@onready var particle_emitter = $Bats

@export var particles_count_dots = 20
@onready var particle_emitter_dots = $Dots


var changing_size = false

var last_direction := Vector2.ZERO
var current_size = 0
var current_ghosts_count = 0
var sizes = [1, 1.5, 2, 2.5, 3, 3.5]

func _ready():
	dash_timer.one_shot = true
	dash_cooldown_timer.one_shot = true
	on_hit_flash_timer.one_shot = true
	ghost_timer.one_shot = true

func _process(delta):
	if on_hit_flash_timer.time_left > 0:
		var normalized_time = on_hit_flash_timer.time_left / on_hit_flash_time
		sprite.material.set_shader_parameter("normalized_time", normalized_time as float)
	animate()

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
		is_anim_walking = false
		return
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction != Vector2(0.0, 0.0):
		last_direction = direction
	velocity = direction * speed
	if velocity.length() > 0.01:
		is_anim_walking = true
	else:
		is_anim_walking = false


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
		ghost_timer.start(ghosts_delay)
		particle_emitter.amount = particle_count_on_success
		particle_emitter_dots.amount = particles_count_dots
		particle_emitter_dots.restart()
		is_anim_in_good_dash = true
		prints("dash in time")
	else:
		dash_speed = dash_speed_not_in_time
		particle_emitter.amount = particle_count_on_failure
		prints("dash not in time")

	particle_emitter.restart()

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
	projectile_node.was_on_beat = MusicGlobalEvents.get_correct_beat_time_left()
	get_parent().add_child(projectile_node)
	
	var wavefront_node = wavefront.instantiate() as Explosion
	wavefront_node.position = position
	wavefront_node.radius = 10
	wavefront_node.starting_radius = 0
	wavefront_node.time = 1
	wavefront_node.was_on_beat = MusicGlobalEvents.get_correct_beat_time_left()
	get_parent().add_child(wavefront_node)
	
	is_super_attack = true
	is_anim_special_attack = true
	super_attack_timer.start(super_attack_time)
	drop_size()
	MusicGlobalEvents.update_combo_state(MusicGlobalEvents.ComboState.SMALL_COMBO)
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
				increased_size_signal.emit(current_size)
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
	if is_invincible:
		return
	if (is_in_dash or is_super_attack) and !force_give_hit:
		return
		
	if current_size == 0:
		#is_died = true
		#LevelManager.reload_scene()
		pass
	else:
		on_hit_flash_timer.start(on_hit_flash_time)
		drop_size()
		MusicGlobalEvents.update_combo_state(MusicGlobalEvents.ComboState.NO_COMBO)

func _on_dash_timer_timeout() -> void:
	is_in_dash = false
	is_in_dash_cooldown = true
	is_dash_in_time = false
	is_anim_in_good_dash = false
	velocity = last_direction * speed
	dash_cooldown_timer.start(dash_cooldown_time)

func increase_size(value = 1):
	changing_size = true
	current_size = clampi(current_size + value, 0, max_size)
	if can_super_attack():
		MusicGlobalEvents.update_combo_state(MusicGlobalEvents.ComboState.BIG_COMBO)
	else:
		MusicGlobalEvents.update_combo_state(MusicGlobalEvents.ComboState.SMALL_COMBO)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(sizes[current_size], sizes[current_size]), 0.1)
	tween.connect("finished", func(): changing_size = false )

func drop_size():
	current_size = 0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(sizes[current_size], sizes[current_size]), 0.1)

func _on_dash_cooldown_timer_timeout() -> void:
	is_in_dash_cooldown = false

func can_super_attack() -> bool:
	return current_size > super_attack_threshold

func _on_super_attack_timer_timeout() -> void:
	is_super_attack = false
	is_anim_special_attack = false
	pass # Replace with function body.

func get_current_size() -> int:
	return current_size

func _on_ghost_timer_timeout():
	current_ghosts_count += 1
	var ghost_node = ghost.instantiate()
	ghost_node.texture = sprite.texture

	ghost_node.global_position = sprite.global_position
	ghost_node.hframes = sprite.hframes
	ghost_node.vframes = sprite.vframes
	ghost_node.frame = sprite.frame #(dsmoliakov): hmmmm frame the last one to update as change of hframes and vframes clearing value
	if (changing_size):
		ghost_node.scale = Vector2(sizes[current_size-1], sizes[current_size-1])
	else:
		ghost_node.scale = Vector2(sizes[current_size], sizes[current_size])
	get_parent().add_child(ghost_node)
	if current_ghosts_count < ghosts_count_dash_in_time:
		ghost_timer.start(ghosts_delay)
	else:
		current_ghosts_count = 0


#region Animation

func animate():
	if is_anim_in_good_dash:
		animate_dash_good()
	elif is_anim_in_bad_dash:
		pass
	elif is_anim_special_attack:
		animate_spit()
	elif is_anim_walking:
		animate_walk()
	else:
		animate_idle() #idle anim

func animate_walk():
	animate_direction(last_direction, "walk_up", "walk_down", "walk_left", "walk_right")


func animate_idle():
	animate_direction(last_direction, "idle_up", "idle_down", "idle_left", "idle_right")


func animate_dash_good():
	animate_direction(last_direction, "dash_good_up", "dash_good_down", "dash_good_left", "dash_good_right")


func animate_spit():
	animate_direction(last_direction, "spit_up", "spit_down", "spit_left", "spit_right")


func animate_direction(animation_direction: Vector2, up: String, down : String, left : String, right: String):
	var anim_x = animation_direction.x
	var anim_y = animation_direction.y
	if abs(anim_x) > abs(anim_y):
		if anim_x > 0:
			animation_player.play(right)
		else:
			animation_player.play(left)
	else:
		if anim_y > 0:
			animation_player.play(down)
		else:
			animation_player.play(up)



#endregion
