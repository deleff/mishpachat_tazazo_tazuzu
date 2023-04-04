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
var target_member: CharacterBody2D
var target_name: String

const MEGAMAN = preload("res://characters/megaman/megaman2.tscn")
const IRONMAN = preload("res://characters/iron_man_2/character_body_2d.tscn")
const SPIDERMAN = preload("res://characters/spider_man_2/character_body_2d.tscn")
const CAPTAINAMERICA = preload("res://characters/captain_america_2/character_body_2d.tscn")

#var family_members_array: Array[PackedScene] = [CAPTAINAMERICA,CAPTAINAMERICA,CAPTAINAMERICA,CAPTAINAMERICA]
var family_members_array: Array[PackedScene] = [MEGAMAN,IRONMAN,SPIDERMAN,CAPTAINAMERICA]
var family_members_on_screen: Array[String]
# Called when the node enters the scene tree for the first time.
func _ready():
	var signal_message_queue = get_node("SignalMessageQueue")
	signal_message_queue.connect("family_member_removed", _on_family_member_removed)
	signal_message_queue.connect("you_win", _on_you_win)
	target_member = family_members_array[random_number_generator.randi_range(0,3)].instantiate()
	add_child(target_member)
	target_name = target_member.NAME
	target_member.queue_free()
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
	spawn_timer.queue_free()
	$RichTextLabel.text = "YAAAAY, You found {target_name}!!!".format({"target_name": target_name})
	$RichTextLabel.position = Vector2(370,330)

func _return_to_title_screen():
	get_tree().change_scene_to_file("res://scenes/TitleScreen/TitleScreen.tscn")

func _generate_family_member(member):
	random_number_generator.randomize()
	family_member_spawn_x = random_number_generator.randi_range(0,1480)
	random_number_generator.randomize()
	family_member_spawn_y = random_number_generator.randi_range(0,720)
	random_number_generator.randomize()
	family_member_direction_x = random_number_generator.randi_range(-1,1)
	random_number_generator.randomize()
	family_member_direction_y = random_number_generator.randi_range(-1,1)
	var next_member = member.instantiate()
	add_child(next_member)
	if family_members_on_screen.has(next_member.NAME):
		next_member.queue_free()
	else:
		family_member_count +=1
		family_members_on_screen.append(next_member.NAME)
		var POTENTIAL_TARGET_POSITION = Vector2(family_member_direction_x, family_member_direction_y)
		if POTENTIAL_TARGET_POSITION == Vector2(0,0):
			POTENTIAL_TARGET_POSITION = Vector2(1,0)
		next_member.position = Vector2(family_member_spawn_x,family_member_spawn_y)
		next_member.TARGET_POSITION = POTENTIAL_TARGET_POSITION
		next_member.SPEED = family_member_speed
		if next_member.NAME == target_name:
			next_member.IS_TARGET = true
		print("Members on screen: ", family_members_on_screen)


func _on_spawn_timer_timeout():
	$RichTextLabel.text = "Find {target_name}!".format({"target_name": target_name})
	random_number_generator.randomize()
	var next_family_member = family_members_array[random_number_generator.randi_range(0,3)]
	print("the family member is: ", next_family_member)
	_generate_family_member(next_family_member)
