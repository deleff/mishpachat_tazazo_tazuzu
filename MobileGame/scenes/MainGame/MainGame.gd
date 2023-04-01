extends Node2D

var spawn_timer = Timer.new()
var spawn_timer_timeout: int
var transition_period = 2
var transition_position = 0

var random_number_generator = RandomNumberGenerator.new()
var family_member_spawn_x: int
var family_member_spawn_y: int
var family_member_direction_x: int
var family_member_direction_y: int
var family_member_count = 0
var family_member_speed: int

const MEGAMAN = preload("res://characters/megaman/megaman2.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$RichTextLabel.text = "Playing on {mode} mode".format({"mode": PersistentData.mode})
	if PersistentData.mode == "easy":
		family_member_speed = 160
		spawn_timer_timeout = 2
	elif PersistentData.mode == "medium":
		family_member_speed = 320
		spawn_timer_timeout = 1
	elif PersistentData.mode == "hard":
		family_member_speed = 480
		spawn_timer_timeout = 0.2
	else:
		print("ERROR: Unknown mode")
	add_child(spawn_timer)
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_text_timer_timeout)
	spawn_timer.start(spawn_timer_timeout)
	print("Mode: ", PersistentData.mode)
	$TitleScreenTouchScreenButton.pressed.connect(_return_to_title_screen)


func _return_to_title_screen():
	get_tree().change_scene_to_file("res://scenes/TitleScreen/TitleScreen.tscn")


func _on_text_timer_timeout():
	random_number_generator.randomize()
	family_member_spawn_x = random_number_generator.randi_range(0,1480)
	random_number_generator.randomize()
	family_member_spawn_y = random_number_generator.randi_range(0,720)
	family_member_count += 1
	random_number_generator.randomize()
	family_member_direction_x = random_number_generator.randi_range(-1,1)
	random_number_generator.randomize()
	family_member_direction_y = random_number_generator.randi_range(-1,1)
	var megaman = MEGAMAN.instantiate()
	add_child(megaman)
	megaman.position = Vector2(family_member_spawn_x,family_member_spawn_y)
	megaman.TARGET_POSITION = Vector2(family_member_direction_x, family_member_direction_y)
	megaman.SPEED = family_member_speed

