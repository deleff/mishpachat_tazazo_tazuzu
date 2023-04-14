extends CharacterBody2D

var movement_timer = Timer.new()
var shrug_timer = Timer.new()
var movement_iterations: int = 0
var walking_speed
var shrug: bool = true
var shrug_iterations: int = 0

func _ready():
	add_child(movement_timer)
	movement_timer.one_shot = false
	movement_timer.start(2)
	movement_timer.timeout.connect(_movement)
	add_child(shrug_timer)
	shrug_timer.one_shot = false
	shrug_timer.start(.5)
	shrug_timer.timeout.connect(_shrug)
	
	walking_speed = Vector2(1,0) * 150

func _movement():
	movement_iterations += 1
	if movement_iterations % 2 == 0 && movement_iterations != 0:
		if $YitzchakSprite2D.texture == load("res://family/yitzchak/yitzchak_walk.png"):
			$YitzchakSprite2D.texture = load("res://family/yitzchak/yitzchak_shrug.png")
			walking_speed = Vector2(0,0) * 0
		else:
			walking_speed = Vector2(1,0) * 150
			$YitzchakSprite2D.texture = load("res://family/yitzchak/yitzchak_walk.png")
	if movement_iterations >= 8:
		print("Yitzchak queue free")
		self.queue_free()
			
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
			walking_speed = Vector2(1,0) * 150

func _physics_process(_delta):
	velocity = walking_speed
	move_and_slide()
