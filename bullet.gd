extends RigidBody2D

var time = 0

func _process(delta: float) -> void:
	time += 1
	
	if time >= 300:
		queue_free()
