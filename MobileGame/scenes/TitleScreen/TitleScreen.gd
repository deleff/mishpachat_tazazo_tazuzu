extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print("starting")
	$EasyModeTouchScreenButton.connect("pressed", self, "_on_easy_mode_pressed")
	$MediumModeTouchScreenButton.connect("pressed", self, "_on_medium_mode_pressed")
	$HardModeTouchScreenButton.connect("pressed", self, "_on_hard_mode_pressed")
	

func _on_easy_mode_pressed():
	SceneLoader.goto_scene("res://scenes/MainGame/MainGame.tscn")
	PersistentData.mode = "easy"

func _on_medium_mode_pressed():
	SceneLoader.goto_scene("res://scenes/MainGame/MainGame.tscn")
	PersistentData.mode = "medium"

func _on_hard_mode_pressed():
	SceneLoader.goto_scene("res://scenes/MainGame/MainGame.tscn")
	PersistentData.mode = "hard"
