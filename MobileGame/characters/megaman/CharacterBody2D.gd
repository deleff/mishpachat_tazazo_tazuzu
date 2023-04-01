extends CharacterBody2D


var SPEED = 300

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	velocity.x -= 100
	velocity.y -= 200

	move_and_slide()
