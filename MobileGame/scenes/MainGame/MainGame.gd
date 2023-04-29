extends Node2D

var spawn_timer = Timer.new()
var num_spawn_timer_timeouts: int = 0
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

const achinoam = preload("res://family/achinoam/character_body_2d.tscn")
const adam     = preload("res://family/adam/character_body_2d.tscn")
const ahuva    = preload("res://family/ahuva/character_body_2d.tscn")
const avigail  = preload("res://family/avigail/character_body_2d.tscn")
const barak    = preload("res://family/barak/character_body_2d.tscn")
const danni    = preload("res://family/danni/character_body_2d.tscn")
const fenti    = preload("res://family/fenti/character_body_2d.tscn")
const gadi     = preload("res://family/gadi/character_body_2d.tscn")
const guy      = preload("res://family/guy/character_body_2d.tscn")
const liah     = preload("res://family/liah/character_body_2d.tscn")
const libbi    = preload("res://family/libbi/character_body_2d.tscn")
const liron    = preload("res://family/liron/character_body_2d.tscn")
const maoz     = preload("res://family/maoz/character_body_2d.tscn")
const messi    = preload("res://family/messi/character_body_2d.tscn")
const moran    = preload("res://family/moran/character_body_2d.tscn")
const natan    = preload("res://family/natan/character_body_2d.tscn")
const oranit   = preload("res://family/oranit/character_body_2d.tscn")
const sivan    = preload("res://family/sivan/character_body_2d.tscn")
const tali     = preload("res://family/tali/character_body_2d.tscn")
const tehilla  = preload("res://family/tehilla/character_body_2d.tscn")
const yafit    = preload("res://family/yafit/character_body_2d.tscn")
const yitzchak = preload("res://family/yitzchak/character_body_2d.tscn")
const yossi    = preload("res://family/yossi/character_body_2d.tscn")

var family_members_array: Array[PackedScene] = [achinoam,adam,ahuva,avigail,barak,danni,fenti,gadi,guy,liah,libbi,liron,maoz,messi,moran,natan,oranit,sivan,tali,tehilla,yafit,yitzchak,yossi]
var family_members_on_screen: Array[String]
# Called when the node enters the scene tree for the first time.
func _ready():
	$TextureRect.texture = load("res://scenes/MainGame/{level}.png".format({"level": PersistentData.level}))
	$AudioStreamPlayer.stream = load("res://sfx/{level}.mp3".format({"level": PersistentData.level}))
	if PersistentData.level == "shire":
		$AudioStreamPlayer.play(5)
	else:
		$AudioStreamPlayer.play()
	add_child(countdown_timer)
	countdown_timer.start(60)
	countdown_timer.one_shot = true
	countdown_timer.timeout.connect(_on_countdown_timer_timeout)
	var signal_message_queue = get_node("SignalMessageQueue")
	signal_message_queue.connect("family_member_removed", _on_family_member_removed)
	signal_message_queue.connect("you_win", _on_you_win)
	signal_message_queue.connect("wrong_person", _on_wrong_person)
	_set_target_family_member()
	$RichTextLabel.text = "[outline_size=20][outline_color=black] [/outline_color][/outline_size]".format({"mode": PersistentData.mode})
	if PersistentData.mode == "easy":
		family_member_speed = 160
		spawn_timer_timeout = 2
	elif PersistentData.mode == "medium":
		family_member_speed = 320
		spawn_timer_timeout = 1.5
	elif PersistentData.mode == "hard":
		family_member_speed = 480
		spawn_timer_timeout = 1
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
	if PersistentData.mode == "hard":
		countdown_timer.start(ceil(countdown_timer.time_left) + 5)
		score+=5
		_set_target_family_member()
	else:
		spawn_timer.queue_free()
		$SfxAudioStreamPlayer.queue_free()
		$RichTextLabel.text = "[outline_size=4][outline_color=black] מצאתם את {target_name} !!! [/outline_color][/outline_size]".format({"target_name": target_name})
		$RichTextLabel.position = Vector2(250,330)
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
	family_member_spawn_y = random_number_generator.randi_range(240,600)
	random_number_generator.randomize()
	family_member_direction_x = random_number_generator.randi_range(-1,1)
	random_number_generator.randomize()
	family_member_direction_y = random_number_generator.randi_range(-1,1)
	var next_member = member.instantiate()
	add_child(next_member)
	
	if PersistentData.mode != "easy":
		if PersistentData.level == "water":
			if family_member_direction_x == 1:
				next_member.rotate(70)
			elif family_member_direction_x == -1:
				next_member.rotate(-70)
			elif family_member_direction_x == 0 && family_member_direction_y == 0:
				next_member.rotate(70)
	
	next_member.NAME = _get_family_member_name(member_position,"string")
	if family_members_on_screen.has(next_member.NAME):
		next_member.queue_free()
		if PersistentData.mode != "easy":
			_on_family_member_removed(next_member.NAME)
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
		if ceil(countdown_timer.time_left) > 10:
			$TimerRichTextLabel.text = "[outline_size=20][outline_color=black] זמן שנשאר:  {time}  [/outline_color][/outline_size]".format({"time": ceil(countdown_timer.time_left)})
		else:
			$TimerRichTextLabel.text = "[outline_size=20][outline_color=black] זמן שנשאר:  [shake]{time}  [/shake][/outline_color][/outline_size]".format({"time": ceil(countdown_timer.time_left)})
		random_number_generator.randomize()
		var next_family_member_position = random_number_generator.randi_range(0,(family_members_array.size() - 1))
		var next_family_member = family_members_array[next_family_member_position]
		print("the family member is: ", next_family_member)
		_generate_family_member(next_family_member,next_family_member_position)
	$RichTextLabel.text = "[right][outline_size=20][outline_color=black] חפשו את [rainbow freq=1.0 sat=0.8 val=0.8]{target_name}[/rainbow]![/outline_color][/outline_size][/right]".format({"target_name": target_name})
	if num_spawn_timer_timeouts > 2 && floor(num_spawn_timer_timeouts) % 11 == 0:
		var next_family_member_position = target_member_position
		var next_family_member = family_members_array[target_member_position]
		print("the family member is: ", next_family_member)
		_generate_family_member(next_family_member,next_family_member_position)
	else:
		random_number_generator.randomize()
		var next_family_member_position = random_number_generator.randi_range(0,(family_members_array.size() - 1))
		var next_family_member = family_members_array[next_family_member_position]
		print("the family member is: ", next_family_member)
		_generate_family_member(next_family_member,next_family_member_position)
	num_spawn_timer_timeouts+=1


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
		$RichTextLabel.text = "[outline_size=4][outline_color=black]Time's up! \nYour score: {your_score} seconds! \nCurrent high score: {high_score} seconds! [/outline_color][/outline_size]".format({"your_score": score, "high_score": PersistentData.high_score})


func _set_target_family_member():
	target_member_position = random_number_generator.randi_range(0,(family_members_array.size() - 1))
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
				member_name = "אחינועם"
			else:
				member_name = "res://sfx/adir.mp3"
		1:
			if return_type == "string":
				member_name = "אדם"
			else:
				member_name = "res://sfx/ben.mp3"
		2:
			if return_type == "string":
				member_name = "סבתא אהובה"
			else:
				member_name = "res://sfx/dad.mp3"
		3:
			if return_type == "string":
				member_name = "אביגיל"
			else:
				member_name = "res://sfx/dassy.mp3"
		4:
			if return_type == "string":
				member_name = "ברק"
			else:
				member_name = "res://sfx/grandma.mp3"
		5:
			if return_type == "string":
				member_name = "דני"
			else:
				member_name = "res://sfx/jack.mp3"
		6:
			if return_type == "string":
				member_name = "פנטי"
			else:
				member_name = "res://sfx/joey.mp3"
		7:
			if return_type == "string":
				member_name = "סבא גדי"
			else:
				member_name = "res://sfx/liah.mp3"
		8:
			if return_type == "string":
				member_name = "גאי"
			else:
				member_name = "res://sfx/meital.mp3"
		9:
			if return_type == "string":
				member_name = "ליאה"
			else:
				member_name = "res://sfx/melissa.mp3"
		10:
			if return_type == "string":
				member_name = "ליבי"
			else:
				member_name = "res://sfx/michelle.mp3"
		11:
			if return_type == "string":
				member_name = "לירון"
			else:
				member_name = "res://sfx/mom.mp3"
		12:
			if return_type == "string":
				member_name = "מעוז"
			else:
				member_name = "res://sfx/ori.mp3"
		13:
			if return_type == "string":
				member_name = "מסי"
			else:
				member_name = "res://sfx/rut.mp3"
		14:
			if return_type == "string":
				member_name = "מורן"
			else:
				member_name = "res://sfx/sophie.mp3"
		15:
			if return_type == "string":
				member_name = "נתן"
			else:
				member_name = "res://sfx/yitzchak.mp3"
		16:
			if return_type == "string":
				member_name = "אורנית"
			else:
				member_name = "res://sfx/zayde.mp3"
		17:
			if return_type == "string":
				member_name = "סיון"
			else:
				member_name = "res://sfx/zevi.mp3"
		18:
			if return_type == "string":
				member_name = "טלי"
			else:
				member_name = "res://sfx/zevi.mp3"
		19:
			if return_type == "string":
				member_name = "תהילה"
			else:
				member_name = "res://sfx/zevi.mp3"
		20:
			if return_type == "string":
				member_name = "יפית"
			else:
				member_name = "res://sfx/zevi.mp3"
		21:
			if return_type == "string":
				member_name = "יצחק"
			else:
				member_name = "res://sfx/zevi.mp3"
		22:
			if return_type == "string":
				member_name = "יוסי"
			else:
				member_name = "res://sfx/zevi.mp3"
	return member_name
