extends Node2D

var random_number_generator = RandomNumberGenerator.new()
var tiny_dance_flip: bool = false
var tiny_dance_flip_iterations: int = 0
var mischief_iterations: int = 0

const yitzchak_scene = preload("res://scenes/TitleScreen/yitzchak_character_body_2d.tscn")
const liah_scene = preload("res://scenes/TitleScreen/liah_character_body_2d.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
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
		mischief_timer.start(5)
		#mischief_timer.start(.005)
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

func _mischief():
	if mischief_iterations % 5 == 0 && mischief_iterations != 0:
		random_number_generator.randomize()
		if random_number_generator.randi_range(0,1) > 0:
			var yitzchak = yitzchak_scene.instantiate()
			add_child(yitzchak)
			yitzchak.position = Vector2(-80,550)
		else:
			var liah = liah_scene.instantiate()
			add_child(liah)
			liah.position = Vector2(random_number_generator.randi_range(300,1000),530)
	mischief_iterations += 1

func _tiny_dance():
	tiny_dance_flip_iterations += 1
	if tiny_dance_flip_iterations % 5 == 0:
		random_number_generator.randomize()
		$TinyDancerSprite2D.texture = load(_get_family_member_sprite(random_number_generator.randi_range(0,17)))
		if tiny_dance_flip_iterations % 2 == 0:
			$TinyDancerSprite2D.position = Vector2(random_number_generator.randi_range(40,350),160)
		else:
			$TinyDancerSprite2D.position = Vector2(random_number_generator.randi_range(40,350),560)
	if tiny_dance_flip == true:
		$TinyDancerSprite2D.flip_h = true
		tiny_dance_flip = false
	else:
		$TinyDancerSprite2D.flip_h = false
		tiny_dance_flip = true

func _get_family_member_sprite(array_number):
	var member_name: String
	match array_number:
		0:
			member_name = "res://family/adir/adir.png"
		1:
			member_name = "res://family/ben/ben.png"
		2:
			member_name = "res://family/dad/dad.png"
		3:
			member_name = "res://family/dassy/dassy.png"
		4:
			member_name = "res://family/grandma/grandma.png"
		5:
			member_name = "res://family/jack/jack.png"
		6:
			member_name = "res://family/joey/joey.png"
		7:
			member_name = "res://family/liah/liah.png"
		8:
			member_name = "res://family/meital/meital.png"
		9:
			member_name = "res://family/melissa/melissa.png"
		10:
			member_name = "res://family/michelle/michelle.png"
		11:
			member_name = "res://family/mom/mom.png"
		12:
			member_name = "res://family/ori/ori.png"
		13:
			member_name = "res://family/rut/rut.png"
		14:
			member_name = "res://family/sophie/sophie.png"
		15:
			member_name = "res://family/yitzchak/yitzchak.png"
		16:
			member_name = "res://family/zayde/zayde.png"
		17:
			member_name = "res://family/zevi/zevi.png"
	return member_name
