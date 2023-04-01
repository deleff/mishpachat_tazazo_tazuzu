extends CharacterBody2D


var SPEED: int
var TARGET_POSITION: Vector2

func _physics_process(delta):
	velocity= TARGET_POSITION * SPEED
	move_and_slide()
	
	if (self.global_position.x < 0 || self.global_position.x > 1480):
		print(self, " off screen")
		self.queue_free()

	if (self.global_position.y < 0 || self.global_position.y > 720):
		print(self, " off screen")
		self.queue_free()

