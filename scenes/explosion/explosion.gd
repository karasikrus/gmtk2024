extends Area2D
class_name Explosion
var radius = 3
var time = 0.5
var starting_radius = 0
@onready var explosionWavefrontTimer = $ExplosionWavefrontTimer
@onready var collisionShape = $CollisionShape2D
@onready var sprite = $Sprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	explosionWavefrontTimer.one_shot = true
	explosionWavefrontTimer.start(time)
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var time_left = explosionWavefrontTimer.time_left
	var normalized_time = 1 - time_left / time
	collisionShape.shape.radius = lerp(starting_radius, radius * 20, normalized_time)
	sprite.scale.x = lerp(starting_radius, radius, normalized_time)
	sprite.scale.y = lerp(starting_radius, radius, normalized_time)
	
	var bodies = get_overlapping_bodies()
	for body in bodies:
		#if body is BasicEnemy:
			
		if body.is_in_group("enemy"):
			var direction = (body.position - position).normalized()
			body.position = position + direction * (collisionShape.shape.radius - 0.05)
	pass
	
	
func _on_explosion_wavefront_timer_timeout() -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemy"):
			body.is_freezed = false
	queue_free()
	pass # Replace with function body.


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.get_hit(Vector2(0, 0), 1)
		body.is_freezed = true
		
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.is_freezed = false

	pass # Replace with function body.
