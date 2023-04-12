extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print("starting")
	$EasyModeTouchScreenButton.pressed.connect(_on_easy_mode_pressed)
	$MediumModeTouchScreenButton.pressed.connect(_on_medium_mode_pressed)
	$HardModeTouchScreenButton.pressed.connect(_on_hard_mode_pressed)
	if PersistentData.title_screen_first_time == true:
		$AudioStreamPlayer.stream = load("res://sfx/title_screen.mp3")
		$TextureRect.texture = load("res://scenes/TitleScreen/title_screen_1.png")
	else:
		var random_number_generator = RandomNumberGenerator.new()
		random_number_generator.randomize()
		if random_number_generator.randi_range(0,1) == 0:
			$TextureRect.texture = load("res://scenes/TitleScreen/title_screen_2.png")
		else:
			$TextureRect.texture = load("res://scenes/TitleScreen/title_screen_3.png")
		$TextureRect.scale = Vector2(1,1)
		$TextureRect.position = Vector2(0,-22)
		$AudioStreamPlayer.stream = load("res://sfx/title_screen_2.mp3")
	$AudioStreamPlayer.play()

#func _process(delta):
#	if ($HardModeTouchScreenButton.is_pressed()):
#		print("hard mode pressed")

func _on_easy_mode_pressed():
	$AudioStreamPlayer.stream = load("res://sfx/select.mp3")
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.5).timeout
	print("easy pressed")
	get_tree().change_scene_to_file("res://scenes/MainGame/MainGame.tscn")
	PersistentData.mode = "easy"

func _on_medium_mode_pressed():
	$AudioStreamPlayer.stream = load("res://sfx/select.mp3")
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.5).timeout
	print("medium pressed")
	get_tree().change_scene_to_file("res://scenes/MainGame/MainGame.tscn")
	PersistentData.mode = "medium"

func _on_hard_mode_pressed():
	$AudioStreamPlayer.stream = load("res://sfx/select.mp3")
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.5).timeout
	print("hard pressed")
	get_tree().change_scene_to_file("res://scenes/MainGame/MainGame.tscn")
	PersistentData.mode = "hard"
