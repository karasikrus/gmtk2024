extends CharacterBody2D


var isFreezed = false
var isDied = false

@export var speed = 400
@export var attack_cooldown_time = 1
@onready var attack_cooldown_timer = $AttackCooldown

var main_player = null

func _ready():
	main_player = (get_tree().get_first_node_in_group("player") as MainCharacter) 
	attack_cooldown_timer.one_shot = true

func attack():
	#(dsmoliakov): technically can't be called when isDied and isFreezed, adding just to make sure
	if isFreezed or isDied:
		return
	isFreezed = true
	attack_cooldown_timer.start(attack_cooldown_time)
	main_player.get_hit(1)
	
func _physics_process(delta):
	if isFreezed or isDied or not main_player:
		return
	
	var direction = main_player.global_position - global_position
	direction = direction.normalized() 
	velocity = direction * speed
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		if collider == main_player:
			attack()
	

	move_and_slide()
	


func _on_attack_cooldown_timeout() -> void:
		isFreezed = false
