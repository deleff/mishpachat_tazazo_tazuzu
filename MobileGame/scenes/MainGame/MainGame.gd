extends Node2D


var text_timer = Timer.new()
var transition_period = 2
var transition_position = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(text_timer)
	text_timer.connect("timeout", self, "_on_text_timer_timeout")
	text_timer.start(2)
	print("Mode: ", PersistentData.mode)
	$TitleScreenTouchScreenButton.connect("pressed", self, "_return_to_title_screen")
	

func _return_to_title_screen():
	SceneLoader.goto_scene("res://scenes/TitleScreen/TitleScreen.tscn")


func _on_text_timer_timeout():
	var print_mode = "Playing on {mode} mode".format({"mode": PersistentData.mode})
	$Tween/RichTextLabel.text = print_mode
