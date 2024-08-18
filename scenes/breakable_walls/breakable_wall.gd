extends StaticBody2D
class_name BreakableWall

@onready var staticBody = $StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

	

func destroy_wall():
	set_collision_mask_value(1, false) #(dsmoliakov): bruh, thats cursed, why it's 1 and not 0
	set_collision_layer_value(1, false)
	queue_free()
