extends Node2D

var random_number_generator = RandomNumberGenerator.new()
var tiny_dance_flip: bool = false
var tiny_dance_flip_iterations: int = 0
var mischief_iterations: int = 0

var TIMES_TAPPED: int = 0

const yitzchak_scene = preload("res://scenes/TitleScreen/yitzchak_character_body_2d.tscn")
const liah_scene = preload("res://scenes/TitleScreen/liah_character_body_2d.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if PersistentData.title_screen_times_tapped > 1:
		get_node("EasyModeTouchScreenButton/RichTextLabel").set_text("[wave amp=50.0 freq=5.0][outline_size=30][outline_color=black]קל[/outline_color][/outline_size][/wave]")
		get_node("MediumModeTouchScreenButton/RichTextLabel").set_text("[wave amp=50.0 freq=5.0][outline_size=30][outline_color=black]בינוני[/outline_color][/outline_size][/wave]")
		get_node("HardModeTouchScreenButton/RichTextLabel").set_text("[wave amp=50.0 freq=5.0][outline_size=30][outline_color=black]קשה[/outline_color][/outline_size][/wave]")

	print("starting")
	$EasyModeTouchScreenButton.pressed.connect(_on_easy_mode_pressed)
	$MediumModeTouchScreenButton.pressed.connect(_on_medium_mode_pressed)
	$HardModeTouchScreenButton.pressed.connect(_on_hard_mode_pressed)
	if PersistentData.title_screen_first_time == true:
		$AudioStreamPlayer.stream = load("res://sfx/title_screen.mp3")
		$TextureRect.texture = load("res://scenes/TitleScreen/title_screen_1.png")
		var mischief_timer = Timer.new()
		add_child(mischief_timer)
		mischief_timer.one_shot = false
		mischief_timer.start(1)
		mischief_timer.timeout.connect(_mischief)
	else:
		random_number_generator.randomize()
		if random_number_generator.randi_range(0,1) == 0:
			$TextureRect.texture = load("res://scenes/TitleScreen/title_screen_2.png")
		else:
			$TextureRect.texture = load("res://scenes/TitleScreen/title_screen_3.png")
		$TextureRect.scale = Vector2(1,1)
		$TextureRect.position = Vector2(0,-22)
		$AudioStreamPlayer.stream = load("res://sfx/title_screen_2.mp3")
		var tiny_dancer_timer = Timer.new()
		add_child(tiny_dancer_timer)
		tiny_dancer_timer.one_shot = false
		tiny_dancer_timer.start(0.25)
		tiny_dancer_timer.timeout.connect(_tiny_dance)
	$AudioStreamPlayer.play()

func _process(delta):
	if PersistentData.title_screen_times_tapped == 1:
			get_node("EasyModeTouchScreenButton/RichTextLabel").set_text("[wave amp=50.0 freq=5.0][outline_size=30][outline_color=black]משפחת[/outline_color][/outline_size][/wave]")
			get_node("MediumModeTouchScreenButton/RichTextLabel").set_text("[wave amp=50.0 freq=5.0][outline_size=30][outline_color=black]תזזו[/outline_color][/outline_size][/wave]")
			get_node("HardModeTouchScreenButton/RichTextLabel").set_text("[wave amp=50.0 freq=5.0][outline_size=30][outline_color=black]תזוזו[/outline_color][/outline_size][/wave]")
	
func _input(event):
	if event is InputEventScreenTouch && event.is_pressed():
		PersistentData.title_screen_times_tapped+=1
		if PersistentData.title_screen_times_tapped == 1:
			get_node("EasyModeTouchScreenButton/RichTextLabel").set_text("[wave amp=50.0 freq=5.0][outline_size=30][outline_color=black]משפחת[/outline_color][/outline_size][/wave]")
			get_node("MediumModeTouchScreenButton/RichTextLabel").set_text("[wave amp=50.0 freq=5.0][outline_size=30][outline_color=black]תזזו[/outline_color][/outline_size][/wave]")
			get_node("HardModeTouchScreenButton/RichTextLabel").set_text("[wave amp=50.0 freq=5.0][outline_size=30][outline_color=black]תזוזו[/outline_color][/outline_size][/wave]")
		elif PersistentData.title_screen_times_tapped > 1:
			get_node("EasyModeTouchScreenButton/RichTextLabel").set_text("[wave amp=50.0 freq=5.0][outline_size=30][outline_color=black]קל[/outline_color][/outline_size][/wave]")
			get_node("MediumModeTouchScreenButton/RichTextLabel").set_text("[wave amp=50.0 freq=5.0][outline_size=30][outline_color=black]בינוני[/outline_color][/outline_size][/wave]")
			get_node("HardModeTouchScreenButton/RichTextLabel").set_text("[wave amp=50.0 freq=5.0][outline_size=30][outline_color=black]קשה[/outline_color][/outline_size][/wave]")

		


func _choose_level():
	random_number_generator.randomize()
	var level = random_number_generator.randi_range(1,7)
	match level:
		1:
			PersistentData.level = "bus"
		2:
			PersistentData.level = "park"
		3:
			PersistentData.level = "shire"
		4:
			PersistentData.level = "space"
		5:
			PersistentData.level = "water"
		6:
			PersistentData.level = "park"
		7:
			PersistentData.level = "main_background"


func _on_easy_mode_pressed():
	$AudioStreamPlayer.stream = load("res://sfx/select.mp3")
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.5).timeout
	print("easy pressed")
	get_tree().change_scene_to_file("res://scenes/MainGame/MainGame.tscn")
	PersistentData.mode = "easy"
	_choose_level()

func _on_medium_mode_pressed():
	$AudioStreamPlayer.stream = load("res://sfx/select.mp3")
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.5).timeout
	print("medium pressed")
	get_tree().change_scene_to_file("res://scenes/MainGame/MainGame.tscn")
	PersistentData.mode = "medium"
	_choose_level()

func _on_hard_mode_pressed():
	$AudioStreamPlayer.stream = load("res://sfx/select.mp3")
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.5).timeout
	print("hard pressed")
	get_tree().change_scene_to_file("res://scenes/MainGame/MainGame.tscn")
	PersistentData.mode = "hard"
	_choose_level()

func _mischief():
	if mischief_iterations == 1:
		var liah = liah_scene.instantiate()
		add_child(liah)
		liah.position = Vector2(1200,530)
	elif mischief_iterations == 4:
		var yitzchak = yitzchak_scene.instantiate()
		add_child(yitzchak)
		yitzchak.position = Vector2(-80,550)
	mischief_iterations += 1

func _tiny_dance():
	pass
