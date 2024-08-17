extends CharacterBody2D
class_name MainCharacter

#(dsmoliakov): common object state
var is_freezed = false
var is_died = false
var is_in_dash = false
var is_in_dash_cooldown = false

@export var speed = 200
@export var dash_speed = 500
@export var max_health = 4
@export var dash_cooldown_time = 0.5
@export var dash_duration = 0.2 #(dsmolikov): smth wrong here tho

@onready var dash_cooldown_timer = $DashCooldownTimer
@onready var dash_timer = $DashTimer

var last_direction = null
var current_health = 4


func _ready():
	current_health = max_health
	dash_timer.one_shot = true
	dash_cooldown_timer.one_shot = true

func _physics_process(delta):
	if is_freezed or is_died:
		return
	
	_process_WASD_input(delta)
	_process_dash(delta)

	move_and_slide()

func _process_WASD_input(delta):
	if is_in_dash:
		return
	var direction = Input.get_vector("left", "right", "up", "down")
	last_direction = direction
	velocity = direction * speed
	

func _process_dash(delta):
	if is_in_dash or is_in_dash_cooldown:
		return
	var is_dash = Input.is_action_pressed("dash")
	if is_dash:
		velocity = last_direction * dash_speed
		dash_timer.start(dash_cooldown_time)
		is_in_dash = true
	
	

func get_hit(damage = 1):
	current_health -= damage
	if current_health <= 0:
		current_health = 0
		is_died = true
		LevelManager.reload_scene()


func _on_dash_timer_timeout() -> void:
	is_in_dash = false
	is_in_dash_cooldown = true
	velocity = last_direction * speed
	dash_cooldown_timer.start(dash_cooldown_time)
	


func _on_dash_cooldown_timer_timeout() -> void:
	is_in_dash_cooldown = false
