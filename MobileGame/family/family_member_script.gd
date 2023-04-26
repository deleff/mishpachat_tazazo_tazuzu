extends CharacterBody2D


var SPEED: int
var TARGET_POSITION: Vector2
var NAME: String
var IS_TARGET: bool = false
var IS_ON_SCREEN: bool = true
var SPRITE_FLIP: bool = true
var DANCE_DIRECTION: int
var random_number_generator = RandomNumberGenerator.new()

@onready var signal_message_queue = get_tree().get_root().get_node("MainGame/SignalMessageQueue")

func _ready():
	random_number_generator.randomize()
	if random_number_generator.randi_range(0,1) == 1:
		DANCE_DIRECTION = 1
	else:
		DANCE_DIRECTION = -1
	$TouchScreenButton.pressed.connect(_tapped)
	signal_message_queue.connect("you_win", _on_you_win)
	if PersistentData.mode != "easy":
			var dance_timer = Timer.new()
			add_child(dance_timer)
			dance_timer.one_shot = false
			dance_timer.start(0.25)
			dance_timer.timeout.connect(_dance)

func _tapped():
	if IS_TARGET == true:
		print("YOU WIN!!")
		signal_message_queue.emit_signal("you_win")
		self.queue_free()
	else:
		signal_message_queue.emit_signal("wrong_person")

func _dance():
	if SPRITE_FLIP == true:
		$Sprite2D.rotate(DANCE_DIRECTION * 0.07)
		SPRITE_FLIP = false
	else:
		$Sprite2D.rotate(DANCE_DIRECTION * -0.07)
		SPRITE_FLIP = true

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

