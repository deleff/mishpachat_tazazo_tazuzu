extends CharacterBody2D

var movement_timer = Timer.new()
var shrug_timer = Timer.new()
var movement_iterations: int = 0
var walking_speed
var shrug: bool = true
var shrug_iterations: int = 0

func _ready():
	if PersistentData.title_screen_times_tapped > 0:
		self.queue_free()
	add_child(movement_timer)
	movement_timer.one_shot = false
	movement_timer.start(1)
	movement_timer.timeout.connect(_movement)
	var random_color = Color(randf(), randf(), randf())
	$GPUParticles2D.process_material.color = random_color
	var random_color_wand = Color(randf(), randf(), randf())
	$WandGPUParticles2D.process_material.color = random_color
	$GPUParticles2D.position.y-=150
	$GPUParticles2D.emitting = true
	await get_tree().create_timer(1).timeout
	$LiahSprite2D.flip_h = true
	$LiahSprite2D.texture = load("res://family/liah/liah_shrug.png")

func _process(delta):
	if PersistentData.title_screen_times_tapped > 0:
		self.queue_free()

func _movement():
	movement_iterations += 1
	if movement_iterations == 4:
		$LiahSprite2D.position.y -= 120
		$LiahSprite2D.texture = load("res://family/liah/liah.png")
	elif movement_iterations == 9:
		$LiahSprite2D.position.y += 120
		$LiahSprite2D.flip_h = false
		$LiahSprite2D.texture = load("res://family/liah/liah_wand.png")
		$WandGPUParticles2D.position.x -= 350
		$WandGPUParticles2D.position.y -= 284
		$WandGPUParticles2D.emitting = true
	elif movement_iterations == 11:
		$LiahSprite2D.position.y -= 120
		$LiahSprite2D.texture = load("res://family/liah/liah.png")
	elif movement_iterations == 12:
		$LiahSprite2D.visible = false
		$GPUParticles2D.position.y -= 120
		$GPUParticles2D.emitting = true
		await get_tree().create_timer(2.5).timeout
		print("Liah queue free")
		self.queue_free()
