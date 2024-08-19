extends Sprite2D

@export var time = 0.4
@onready var life_timer = $Timer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, time)
	life_timer.one_shot = true
	life_timer.start(time)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	queue_free()
