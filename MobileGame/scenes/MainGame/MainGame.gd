extends Node2D


var text_timer = Timer.new()
var transition_period = 2
var transition_position = 0

const MEGAMAN = preload("res://characters/megaman/megaman.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(text_timer)
	text_timer.one_shot = true
	text_timer.timeout.connect(_on_text_timer_timeout)
#	text_timer.connect("timeout", self, "_on_text_timer_timeout")
	text_timer.start(2)
	print("Mode: ", PersistentData.mode)
	$TitleScreenTouchScreenButton.pressed.connect(_return_to_title_screen)
	#$TitleScreenTouchScreenButton.connect("pressed", self, "_return_to_title_screen")


func _return_to_title_screen():
	get_tree().change_scene_to_file("res://scenes/TitleScreen/TitleScreen.tscn")


func _on_text_timer_timeout():
	var print_mode = "Playing on {mode} mode".format({"mode": PersistentData.mode})
	print(print_mode)
	$RichTextLabel.text = print_mode
	var megaman = MEGAMAN.instantiate()
	add_child(megaman)
	megaman.position = Vector2(400,400)
