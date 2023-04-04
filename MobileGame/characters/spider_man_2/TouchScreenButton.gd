extends TouchScreenButton

@onready var signal_message_queue = get_tree().get_root().get_node("MainGame/SignalMessageQueue")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_pressed():
		print("YOU WIN")
		signal_message_queue.emit_signal("you_win")
	pass
