extends KinematicBody2D


var gravity = 192.08
var friction = 0.35
var speed = 96
var acceleration = 0.75
var motion = Vector2(0, 0)
var jump_force_multiplier = 0.5
var jumping = false

var left_down = false
var right_down = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if not event.is_echo():
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
	
	var snap_vec = Vector2(0, 1)
	if jumping:
		snap_vec = Vector2.ZERO
		jumping = false
		motion.y -= (gravity * jump_force_multiplier)
		
	motion = move_and_slide_with_snap(motion, snap_vec, Vector2(0, -1), false, 4, 0.785398, true)
