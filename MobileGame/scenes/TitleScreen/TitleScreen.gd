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
	#$EasyModeTouchScreenButton.is_pressed(self._on_easy_mode_pressed())
	#$MediumModeTouchScreenButton.is_pressed(self._on_medium_mode_pressed())
	#$HardModeTouchScreenButton.is_pressed(self._on_hard_mode_pressed())

#func _process(delta):
#	if ($HardModeTouchScreenButton.is_pressed()):
#		print("hard mode pressed")

func _on_easy_mode_pressed():
	print("easy pressed")
	get_tree().change_scene_to_file("res://scenes/MainGame/MainGame.tscn")
	PersistentData.mode = "easy"

func _on_medium_mode_pressed():
	print("medium pressed")
	get_tree().change_scene_to_file("res://scenes/MainGame/MainGame.tscn")
	PersistentData.mode = "medium"

func _on_hard_mode_pressed():
	print("hard pressed")
	get_tree().change_scene_to_file("res://scenes/MainGame/MainGame.tscn")
	PersistentData.mode = "hard"
