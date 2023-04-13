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

const adir = preload("res://family/adir/character_body_2d.tscn")
const ben = preload("res://family/ben/character_body_2d.tscn")
const dad = preload("res://family/dad/character_body_2d.tscn")
const dassy = preload("res://family/dassy/character_body_2d.tscn")
const grandma = preload("res://family/grandma/character_body_2d.tscn")
const jack = preload("res://family/jack/character_body_2d.tscn")
const joey = preload("res://family/joey/character_body_2d.tscn")
const liah = preload("res://family/liah/character_body_2d.tscn")
const meital = preload("res://family/meital/character_body_2d.tscn")
const melissa = preload("res://family/melissa/character_body_2d.tscn")
const michelle = preload("res://family/michelle/character_body_2d.tscn")
const mom = preload("res://family/mom/character_body_2d.tscn")
const ori = preload("res://family/ori/character_body_2d.tscn")
const rut = preload("res://family/rut/character_body_2d.tscn")
const sophie = preload("res://family/sophie/character_body_2d.tscn")
const yitzchak = preload("res://family/yitzchak/character_body_2d.tscn")
const zayde = preload("res://family/zayde/character_body_2d.tscn")
const zevi = preload("res://family/zevi/character_body_2d.tscn")

var family_members_array: Array[PackedScene] = [adir,ben,dad,dassy,grandma,jack,joey,liah,meital,melissa,michelle,mom,ori,rut,sophie,yitzchak,zayde,zevi]
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
	signal_message_queue.connect("wrong_person", _on_wrong_person)
	_set_target_family_member()
	$RichTextLabel.text = "[outline_size=20][outline_color=black]Playing on {mode} mode[/outline_color][/outline_size]".format({"mode": PersistentData.mode})
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
		countdown_timer.start(ceil(countdown_timer.time_left) + 10)
		score+=10
		_set_target_family_member()
	else:
		spawn_timer.queue_free()
		$SfxAudioStreamPlayer.queue_free()
		$RichTextLabel.text = "YAAAAY, You found {target_name}!!!".format({"target_name": target_name})
		$RichTextLabel.position = Vector2(225,330)
		$AudioStreamPlayer.stream = load("res://sfx/win.mp3")
		$AudioStreamPlayer.play()
		var firework_timer = Timer.new()
		add_child(firework_timer)
		firework_timer.one_shot = false
		firework_timer.start(0.5)
		firework_timer.timeout.connect(_fireworks)
		

func _fireworks():
	var random_color = Color(randf(), randf(), randf())
	$GPUParticles2D.process_material.color = random_color
	random_number_generator.randomize()
	var firework_x = random_number_generator.randi_range(50,1380)
	random_number_generator.randomize()
	var firework_y = random_number_generator.randi_range(50,650)
	$GPUParticles2D.position = Vector2(firework_x,firework_y)
	$GPUParticles2D.emitting = true


func _return_to_title_screen():
	PersistentData.title_screen_first_time = false
	get_tree().change_scene_to_file("res://scenes/TitleScreen/TitleScreen.tscn")

func _generate_family_member(member,member_position):
	random_number_generator.randomize()
	family_member_spawn_x = random_number_generator.randi_range(150,1380)
	random_number_generator.randomize()
	family_member_spawn_y = random_number_generator.randi_range(200,600)
	random_number_generator.randomize()
	family_member_direction_x = random_number_generator.randi_range(-1,1)
	random_number_generator.randomize()
	family_member_direction_y = random_number_generator.randi_range(-1,1)
	var next_member = member.instantiate()
	add_child(next_member)
	next_member.NAME = _get_family_member_name(member_position,"string")
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
		$TimerRichTextLabel.text = "[outline_size=20][outline_color=black] Time left: {time}[/outline_color][/outline_size]".format({"time": ceil(countdown_timer.time_left)})
		random_number_generator.randomize()
		var next_family_member_position = random_number_generator.randi_range(0,17)
		var next_family_member = family_members_array[next_family_member_position]
		print("the family member is: ", next_family_member)
		_generate_family_member(next_family_member,next_family_member_position)
	$RichTextLabel.text = "[outline_size=20][outline_color=black]Find [rainbow freq=1.0 sat=0.8 val=0.8]{target_name} [/rainbow]![/outline_color][/outline_size]".format({"target_name": target_name})
	random_number_generator.randomize()
	var next_family_member_position = random_number_generator.randi_range(0,17)
	var next_family_member = family_members_array[next_family_member_position]
	print("the family member is: ", next_family_member)
	_generate_family_member(next_family_member,next_family_member_position)

func _on_countdown_timer_timeout():
	if PersistentData.mode == "hard":
		$SfxAudioStreamPlayer.stream = load("res://sfx/times_up.mp3")
		$SfxAudioStreamPlayer.play()
		if score >= PersistentData.high_score:
			PersistentData.high_score = score
			$AudioStreamPlayer.stream = load("res://sfx/high_score.mp3")
			var firework_timer = Timer.new()
			add_child(firework_timer)
			firework_timer.one_shot = false
			firework_timer.start(0.5)
			firework_timer.timeout.connect(_fireworks)
		else:
			$AudioStreamPlayer.stream = load("res://sfx/not_high_score.mp3")
		$AudioStreamPlayer.play()
		spawn_timer.stop()
		spawn_timer.queue_free()
		$TimerRichTextLabel.queue_free()
		$RichTextLabel.position = Vector2(200,330)
		$RichTextLabel.text = "Time's up! \nYour score: {your_score} seconds! \nCurrent high score: {high_score} seconds!".format({"your_score": score, "high_score": PersistentData.high_score})


func _set_target_family_member():
	target_member_position = random_number_generator.randi_range(0,17)
	target_member = family_members_array[target_member_position].instantiate()
	add_child(target_member)
	target_name = _get_family_member_name(target_member_position,"string")
	target_member.queue_free()
	$SfxAudioStreamPlayer.stream = load("res://sfx/find.mp3")
	$SfxAudioStreamPlayer.play()
	var target_name_mp3 = _get_family_member_name(target_member_position,"mp3")
	await get_tree().create_timer(1).timeout
	$SfxAudioStreamPlayer.stream = load(target_name_mp3)
	$SfxAudioStreamPlayer.play()
	
func _on_wrong_person():
	random_number_generator.randomize()
	var wrong_person_mp3 = random_number_generator.randi_range(0,1)
	if wrong_person_mp3 == 1:
		$SfxAudioStreamPlayer.stream = load("res://sfx/no.mp3")
	else:
		$SfxAudioStreamPlayer.stream = load("res://sfx/try_again.mp3")
	$SfxAudioStreamPlayer.play()

func _get_family_member_name(array_number, return_type):
	var member_name: String
	match array_number:
		0:
			if return_type == "string":
				member_name = "Adir"
			else:
				member_name = "res://sfx/adir.mp3"
		1:
			if return_type == "string":
				member_name = "Ben"
			else:
				member_name = "res://sfx/ben.mp3"
		2:
			if return_type == "string":
				member_name = "Sabba Scott"
			else:
				member_name = "res://sfx/dad.mp3"
		3:
			if return_type == "string":
				member_name = "Dassy"
			else:
				member_name = "res://sfx/dassy.mp3"
		4:
			if return_type == "string":
				member_name = "Savta Rabbah"
			else:
				member_name = "res://sfx/grandma.mp3"
		5:
			if return_type == "string":
				member_name = "Jack"
			else:
				member_name = "res://sfx/jack.mp3"
		6:
			if return_type == "string":
				member_name = "Joey"
			else:
				member_name = "res://sfx/joey.mp3"
		7:
			if return_type == "string":
				member_name = "Liah"
			else:
				member_name = "res://sfx/liah.mp3"
		8:
			if return_type == "string":
				member_name = "Meital"
			else:
				member_name = "res://sfx/meital.mp3"
		9:
			if return_type == "string":
				member_name = "Melissa"
			else:
				member_name = "res://sfx/melissa.mp3"
		10:
			if return_type == "string":
				member_name = "Michelle"
			else:
				member_name = "res://sfx/michelle.mp3"
		11:
			if return_type == "string":
				member_name = "Savta Susan"
			else:
				member_name = "res://sfx/mom.mp3"
		12:
			if return_type == "string":
				member_name = "Ori"
			else:
				member_name = "res://sfx/ori.mp3"
		13:
			if return_type == "string":
				member_name = "Ruth"
			else:
				member_name = "res://sfx/rut.mp3"
		14:
			if return_type == "string":
				member_name = "Sophie"
			else:
				member_name = "res://sfx/sophie.mp3"
		15:
			if return_type == "string":
				member_name = "David"
			else:
				member_name = "res://sfx/yitzchak.mp3"
		16:
			if return_type == "string":
				member_name = "Sabba Rabbah"
			else:
				member_name = "res://sfx/zayde.mp3"
		17:
			if return_type == "string":
				member_name = "Zev"
			else:
				member_name = "res://sfx/zevi.mp3"
	return member_name
