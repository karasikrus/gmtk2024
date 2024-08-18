extends CharacterBody2D
class_name BasicEnemy
@export var max_health = 3
@export var speed = 10
@export var speed_on_dash = 50
@export var on_hit_speed = 100
@export var attack_cooldown_time = 1
@onready var attack_cooldown_timer = $AttackCooldown


var is_freezed = false
var is_died = false
var is_on_hit_cooldown = false
var is_on_beat_dash = false
@onready var health = max_health

@export var on_hit_cooldown_time = 0.1
@onready var on_hit_cooldown_timer = $OnHitCooldown

@export var beat_dash_time = 0.1
@onready var beat_dash_timer = $BeatDashTimer


var main_player = null

func _ready():
	main_player = (get_tree().get_first_node_in_group("player") as MainCharacter) 
	attack_cooldown_timer.one_shot = true
	on_hit_cooldown_timer.one_shot = true
	beat_dash_timer.one_shot = true
	MusicGlobalEvents.beat.connect(_on_beat_dash_start)
	EnemyManager.add_to_enemy_count(self)


func attack():
	#(dsmoliakov): technically can't be called when isDied and isFreezed, adding just to make sure
	if is_freezed or is_died or is_on_hit_cooldown:
		return
	is_freezed = true
	attack_cooldown_timer.start(attack_cooldown_time)
	main_player.get_hit(1)
	
func _physics_process(delta):
	if is_freezed or is_died or not main_player:
		return
	
	if not is_on_hit_cooldown and not is_on_beat_dash:
		var direction = main_player.global_position - global_position
		direction = direction.normalized() 
		velocity = direction * speed
		
	_process_collision(delta)
	move_and_slide()
	

func _process_collision(delta):
	var collision = move_and_collide(velocity * delta)
	
	if not collision:
		return
		
	var collider = collision.get_collider()
	if collider == main_player:
		attack()

func _on_attack_cooldown_timeout() -> void:
	is_freezed = false
	
func can_get_hit():
	return true
	
func kill():
	#(dsmoliakov): probably do animation
	is_died = true
	set_collision_mask_value(1, false) #(dsmoliakov): bruh, thats cursed, why it's 1 and not 0
	set_collision_layer_value(1, false)
	EnemyManager.remove_from_enemy_count(self)
	queue_free()
	
func get_hit(direction, damage = 1):
	if is_died:
		return
	is_on_hit_cooldown = true
	on_hit_cooldown_timer.start(on_hit_cooldown_time)
	velocity = direction * on_hit_speed
	health -= damage
	if health <= 0:
		kill()
	pass
	


func _on_on_hit_cooldown_timeout() -> void:
	is_on_hit_cooldown = false
	pass # Replace with function body.


func _on_beat_dash_start(t) -> void:
	beat_dash_timer.start(beat_dash_time)
	is_on_beat_dash = true
	velocity = velocity.normalized() * speed_on_dash
	pass
	


func _on_beat_dash_timer_timeout() -> void:
	is_on_beat_dash = false
	pass # Replace with function body.
