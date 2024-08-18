extends Area2D

var velocity = 50
var direction = Vector2(0, 0)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * velocity * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.get_hit()
	#queue_free()
