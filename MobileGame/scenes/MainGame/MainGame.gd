extends Node2D

var spawn_timer = Timer.new()
var spawn_timer_timeout: int
var score: int = 60
var countdown_timer = Timer.new()

var random_number_generator = RandomNumberGenerator.new()
var family_member_spawn_x: int
var family_member_spawn_y: int
var family_member_direction_x: int
var family_member_direction_y: int
var family_member_count = 0
var family_member_speed: int
var target_member: CharacterBody2D
var target_member_position: int
var target_name: String

#const MEGAMAN = preload("res://characters/megaman/megaman2.tscn")
#const IRONMAN = preload("res://characters/iron_man_2/character_body_2d.tscn")
#const SPIDERMAN = preload("res://characters/spider_man_2/character_body_2d.tscn")
#const CAPTAINAMERICA = preload("res://characters/captain_america_2/character_body_2d.tscn")

const adir = preload("res://family/adir/character_body_2d.tscn")
const ben = preload("res://family/ben/character_body_2d.tscn")
const dad = preload("res://family/dad/character_body_2d.tscn")
const dassy = preload("res://family/dassy/character_body_2d.tscn")
const grandma = preload("res://family/grandma/character_body_2d.tscn")
const jack = preload("res://family/jack/character_body_2d.tscn")
const joey = preload("res://family/joey/character_body_2d.tscn")
#const liah = preload("res://family/liah/character_body_2d.tscn")
const meital = preload("res://family/meital/character_body_2d.tscn")
const melissa = preload("res://family/melissa/character_body_2d.tscn")
const michelle = preload("res://family/michelle/character_body_2d.tscn")
const mom = preload("res://family/mom/character_body_2d.tscn")
const ori = preload("res://family/ori/character_body_2d.tscn")
const rut = preload("res://family/rut/character_body_2d.tscn")
const sophie = preload("res://family/sophie/character_body_2d.tscn")
#const yitzchak = preload("res://family/yitzchak/character_body_2d.tscn")
const zayde = preload("res://family/zayde/character_body_2d.tscn")
const zevi = preload("res://family/zevi/character_body_2d.tscn")



#var family_members_array: Array[PackedScene] = [MEGAMAN,IRONMAN,SPIDERMAN,CAPTAINAMERICA]
var family_members_array: Array[PackedScene] = [adir,ben,dad,dassy,grandma,jack,joey,meital,melissa,michelle,mom,ori,rut,sophie,zayde,zevi]
var family_members_on_screen: Array[String]
# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(countdown_timer)
	countdown_timer.start(60)
	countdown_timer.one_shot = true
	countdown_timer.timeout.connect(_on_countdown_timer_timeout)
	var signal_message_queue = get_node("SignalMessageQueue")
	signal_message_queue.connect("family_member_removed", _on_family_member_removed)
	signal_message_queue.connect("you_win", _on_you_win)
	_set_target_family_member()
	$RichTextLabel.text = "Playing on {mode} mode".format({"mode": PersistentData.mode})
	if PersistentData.mode == "easy":
		family_member_speed = 160
		spawn_timer_timeout = 2
		$AudioStreamPlayer.stream = load("res://sfx/easy_mode.mp3")
	elif PersistentData.mode == "medium":
		family_member_speed = 320
		spawn_timer_timeout = 1.5
		$AudioStreamPlayer.stream = load("res://sfx/medium_mode.mp3")
	elif PersistentData.mode == "hard":
		family_member_speed = 480
		spawn_timer_timeout = 1
		$AudioStreamPlayer.stream = load("res://sfx/hard_mode.mp3")
	else:
		print("ERROR: Unknown mode")
	$AudioStreamPlayer.play()
	add_child(spawn_timer)
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start(spawn_timer_timeout)
	print("Mode: ", PersistentData.mode)
	$TitleScreenTouchScreenButton.pressed.connect(_return_to_title_screen)


func _on_family_member_removed(member_name):
	family_member_count -=1
	family_members_on_screen.erase(member_name)
	print("SIGNAL TO REMOVE ", member_name)
	print("Family members on screen: ", family_member_count)

func _on_you_win():
	if PersistentData.mode == "hard":
		countdown_timer.start(ceil(countdown_timer.time_left) + 30)
		score+=30
		_set_target_family_member()
	else:
		spawn_timer.queue_free()
		$RichTextLabel.text = "YAAAAY, You found {target_name}!!!".format({"target_name": target_name})
		$RichTextLabel.position = Vector2(370,330)
		$AudioStreamPlayer.stream = load("res://sfx/win.mp3")
		$AudioStreamPlayer.play()

func _return_to_title_screen():
	PersistentData.title_screen_first_time = false
	get_tree().change_scene_to_file("res://scenes/TitleScreen/TitleScreen.tscn")

func _generate_family_member(member,member_position):
	random_number_generator.randomize()
	family_member_spawn_x = random_number_generator.randi_range(150,1380)
	random_number_generator.randomize()
	family_member_spawn_y = random_number_generator.randi_range(150,600)
	random_number_generator.randomize()
	family_member_direction_x = random_number_generator.randi_range(-1,1)
	random_number_generator.randomize()
	family_member_direction_y = random_number_generator.randi_range(-1,1)
	var next_member = member.instantiate()
	add_child(next_member)
	next_member.NAME = _get_family_member_name(member_position)
	if family_members_on_screen.has(next_member.NAME):
		next_member.queue_free()
	else:
		family_member_count +=1
		family_members_on_screen.append(next_member.NAME)
		var POTENTIAL_TARGET_POSITION = Vector2(family_member_direction_x, family_member_direction_y)
		if POTENTIAL_TARGET_POSITION == Vector2(0,0):
			POTENTIAL_TARGET_POSITION = Vector2(1,0)
		next_member.position = Vector2(family_member_spawn_x,family_member_spawn_y)
		if PersistentData.mode == "easy":
			next_member.TARGET_POSITION = Vector2(0,0)
		else:
			next_member.TARGET_POSITION = POTENTIAL_TARGET_POSITION
		next_member.SPEED = family_member_speed
		if member_position == target_member_position:
			next_member.IS_TARGET = true
		print("Members on screen: ", family_members_on_screen)


func _on_spawn_timer_timeout():
	if PersistentData.mode == "hard":
		$TimerRichTextLabel.text = "Time left: {time}".format({"time": ceil(countdown_timer.time_left)})
	$RichTextLabel.text = "Find {target_name}!".format({"target_name": target_name})
	random_number_generator.randomize()
	var next_family_member_position = random_number_generator.randi_range(0,15)
	var next_family_member = family_members_array[next_family_member_position]
	print("the family member is: ", next_family_member)
	_generate_family_member(next_family_member,next_family_member_position)

func _on_countdown_timer_timeout():
	if PersistentData.mode == "hard":
		if score > PersistentData.high_score:
			PersistentData.high_score = score
			$AudioStreamPlayer.stream = load("res://sfx/high_score.mp3")
		else:
			$AudioStreamPlayer.stream = load("res://sfx/not_high_score.mp3")
		$AudioStreamPlayer.play()
		spawn_timer.stop()
		spawn_timer.queue_free()
		$TimerRichTextLabel.queue_free()
		$RichTextLabel.position = Vector2(370,330)
		$RichTextLabel.text = "Time's up! \nYour score: {your_score} seconds! \nCurrent high score: {high_score} seconds!".format({"your_score": score, "high_score": PersistentData.high_score})


func _set_target_family_member():
	target_member_position = random_number_generator.randi_range(0,15)
	target_member = family_members_array[target_member_position].instantiate()
	add_child(target_member)
	target_name = _get_family_member_name(target_member_position)
	target_member.queue_free()


func _get_family_member_name(array_number):
	var member_name: String
	match array_number:
		0:
			member_name = "Adir"
		1:
			member_name = "Ben"
		2:
			member_name = "Sabba Scott"
		3:
			member_name = "Dassy"
		4:
			member_name = "Savta Rabbah"
		5:
			member_name = "Jack"
		6:
			member_name = "Joey"
		7:
			member_name = "Meital"
		8:
			member_name = "Melissa"
		9:
			member_name = "Michelle"
		10:
			member_name = "Savta Susan"
		11:
			member_name = "Ori"
		12:
			member_name = "Ruth"
		13:
			member_name = "Sophie"
		14:
			member_name = "Sabba Rabbah"
		15:
			member_name = "Zev"
	return member_name
