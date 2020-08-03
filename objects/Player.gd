extends KinematicBody2D


var gravity = 192.08
var friction = 0.35
var speed = 96
var acceleration = 0.75
var motion = Vector2(0, 0)
var jump_force_multiplier = 0.5
var jumping = false

var last_mouse_pos = null

var left_down = false
var right_down = false

var idle_time = 0.0
var idle_breath_time = rand_range(1.0, 4.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event):
	if event is InputEventMouseMotion:
		last_mouse_pos = event.position
	elif not event.is_echo():
		if event.is_action_pressed("p1_left"):
			left_down = true
		elif event.is_action_released("p1_left"):
			left_down = false
			
		if event.is_action_pressed("p1_right"):
			right_down = true
		elif event.is_action_released("p1_right"):
			right_down = false
		
		if event.is_action_pressed("p1_jump") and is_on_floor():
			jumping = true

func _physics_process(delta):
	motion.y += (gravity * delta)
	
	var dir = 0
	if left_down:
		dir -= 1
	if right_down:
		dir += 1
	if dir != 0:
		motion.x = lerp(motion.x, (dir * speed), acceleration * delta)
	else:
		motion.x = lerp(motion.x, 0, friction)
		if motion.x < 0.01:
			motion.x = 0
	
	var snap_vec = Vector2(0, 1)
	if jumping:
		snap_vec = Vector2.ZERO
		jumping = false
		motion.y -= (gravity * jump_force_multiplier)
	
	_handle_animations(delta, dir)
	motion = move_and_slide_with_snap(motion, snap_vec, Vector2(0, -1), false, 4, 0.785398, true)


func _handle_animations(delta, direction):
	if direction == -1:
		$ASprite.flip_h = true
	elif direction == 1:
		$ASprite.flip_h = false
	
	if is_on_floor():
		if motion.x != 0:
			$ASprite.animation = "Move"
		else:
			_handle_idle_animations(delta)
	else:
		if motion.y < 0:
			$ASprite.animation = "Jump"
		elif motion.y > 0:
			$ASprite.animation = "Fall"

func _handle_idle_animations(delta):
	if $ASprite.animation != "Breath" and $ASprite.animation != "Idle":
		$ASprite.play("Idle")
	else:
		if $ASprite.animation == "Breath" and not $ASprite.is_playing():
			$ASprite.animation = "Idle"
			$ASprite.play("Idle")
			idle_time = 0
			idle_breath_time = rand_range(1.0, 4.0)
		elif idle_time >= idle_breath_time:
			$ASprite.play("Breath")
		else:
			idle_time += delta
			
		

