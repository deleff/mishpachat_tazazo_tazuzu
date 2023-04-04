extends CharacterBody2D


var SPEED: int
var TARGET_POSITION: Vector2
var NAME: String = "Spider-Man"
var IS_TARGET: bool = false

@onready var signal_message_queue = get_tree().get_root().get_node("MainGame/SignalMessageQueue")

func _ready():
	print("hello")

func _physics_process(delta):
	velocity = TARGET_POSITION * SPEED
	move_and_slide()
	
	if (self.global_position.x < 0 || self.global_position.x > 1480):
		print("Spider-Man", " off screen")		
		self.queue_free()

	if (self.global_position.y < 0 || self.global_position.y > 720):
		print("Spider-Man", " off screen")
		signal_message_queue.emit_signal("family_member_removed")
		self.queue_free()

