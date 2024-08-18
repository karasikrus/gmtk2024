extends Node2D
class_name Projectile
var direction = Vector2(0, 0)
var velocity = 50
var size = 1

var sizes = [1, 2, 3, 4, 5]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apply_scale(Vector2(sizes[size], sizes[size]))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += delta * direction * velocity


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.can_get_hit():
		body.kill()
		
	if body.is_in_group("strong_breakable_wall"):
		body.destroy_wall()
