extends CharacterBody2D
class_name MainCharacter

var isFreezed = false
var isDied = false

@export var speed = 400
@export var max_health = 4

var current_health = 4

func _ready():
	current_health = max_health

func _physics_process(delta):
	if isFreezed or isDied:
		return
	
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()


func get_hit(damage = 1):
	current_health -= damage
	if current_health <= 0:
		current_health = 0
		isDied = true
		LevelManager.reload_scene()
