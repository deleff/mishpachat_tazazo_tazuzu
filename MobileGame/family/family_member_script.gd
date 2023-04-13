extends CharacterBody2D


var SPEED: int
var TARGET_POSITION: Vector2
var NAME: String
var IS_TARGET: bool = false
var IS_ON_SCREEN: bool = true

@onready var signal_message_queue = get_tree().get_root().get_node("MainGame/SignalMessageQueue")

func _ready():
	$TouchScreenButton.pressed.connect(_tapped)
	signal_message_queue.connect("you_win", _on_you_win)

func _tapped():
	if IS_TARGET == true:
		print("YOU WIN!!")
		signal_message_queue.emit_signal("you_win")
		self.queue_free()
	else:
		signal_message_queue.emit_signal("wrong_person")

func _on_you_win():
	self.queue_free()

func _physics_process(delta):
	velocity = TARGET_POSITION * SPEED
	move_and_slide()
	
	if (self.global_position.x < 0 || self.global_position.x > 1480):
		print(NAME, " off screen")		
		signal_message_queue.emit_signal("family_member_removed", NAME)
		self.queue_free()

	if (self.global_position.y < 0 || self.global_position.y > 720):
		print(NAME, " off screen")
		signal_message_queue.emit_signal("family_member_removed", NAME)
		self.queue_free()

