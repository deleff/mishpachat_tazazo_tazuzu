extends CharacterBody2D

var movement_timer = Timer.new()
var shrug_timer = Timer.new()
var movement_iterations: int = 0
var walking_speed
var shrug: bool = true
var shrug_iterations: int = 0
var dance_timer = Timer.new()
var dance_iteration: int = 1

func _ready():
	if PersistentData.title_screen_times_tapped > 0:
		self.queue_free()
	add_child(movement_timer)
	movement_timer.one_shot = false
	movement_timer.start(2)
	movement_timer.timeout.connect(_movement)
	add_child(shrug_timer)
	shrug_timer.one_shot = false
	shrug_timer.start(.5)
	shrug_timer.timeout.connect(_shrug)
	
	walking_speed = Vector2(1,0) * 150
	
	add_child(dance_timer)
	dance_timer.one_shot = false
	dance_timer.start(0.25)
	dance_timer.timeout.connect(_dance)

func _process(delta):
	if PersistentData.title_screen_times_tapped > 0:
		self.queue_free()

func _movement():
	movement_iterations += 1
	if movement_iterations == 2 || movement_iterations == 4:
		if $YitzchakSprite2D.texture == load("res://family/yitzchak/yitzchak_walk.png"):
			$YitzchakSprite2D.texture = load("res://family/yitzchak/yitzchak_shrug.png")
			walking_speed = Vector2(0,0) * 0
		else:
			walking_speed = Vector2(1,0) * 150
			$YitzchakSprite2D.texture = load("res://family/yitzchak/yitzchak_walk.png")
	if movement_iterations >= 8:
		print("Yitzchak queue free")
		self.queue_free()

func _dance():
	if $YitzchakSprite2D.texture != load("res://family/yitzchak/yitzchak_shrug.png"):
		if movement_iterations < 1 || movement_iterations > 4:
			if dance_iteration == 1:
				$YitzchakSprite2D.rotate(0.04)
				$YitzchakSprite2D.position.y += 10
				dance_iteration+=1
			else:
				$YitzchakSprite2D.rotate(-0.04)
				$YitzchakSprite2D.position.y -= 10
				dance_iteration = 1

			
func _shrug():
	if $YitzchakSprite2D.texture == load("res://family/yitzchak/yitzchak_shrug.png"):
		shrug_iterations += 1
		if shrug == true:
			$YitzchakSprite2D.flip_h = true
			shrug = false
		else:
			$YitzchakSprite2D.flip_h = false
			shrug = true
		if shrug_iterations > 3:
			shrug_iterations = 0
			$YitzchakSprite2D.flip_h = false
			$YitzchakSprite2D.texture = load("res://family/yitzchak/yitzchak_walk.png")
			walking_speed = Vector2(-1,0) * 150

func _physics_process(_delta):
	if movement_iterations == 5:
		$YitzchakSprite2D.flip_h = true
	if movement_iterations < 1 || movement_iterations > 4:
		velocity = walking_speed
		move_and_slide()
