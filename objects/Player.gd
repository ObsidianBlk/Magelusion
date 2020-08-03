extends KinematicBody2D

const COLOR_NO_SPELL = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_LIGHT_SPELL = Color(1.0, 1.0, 0.0, 1.0)
const COLOR_FIRE_SPELL = Color(1.0, 0.0, 0.25, 1.0)
const COLOR_WATER_SPELL = Color(0.0, 0.25, 1.0, 1.0)

const PLATFORM_BIT = 1

var gravity = 192.08
var friction = 0.35
var speed = 96
var acceleration = 0.75
var motion = Vector2(0, 0)
var jump_force_multiplier = 0.5
var jumping = false
var casting = false
var caststate = 0

var last_mouse_pos = null

var left_down = false
var right_down = false
var down_down = false

var idle_time = 0.0
var idle_breath_time = rand_range(1.0, 4.0)

var print_delay = 1.0


signal death(who)

# Called when the node enters the scene tree for the first time.
func _ready():
	$ASprite.connect("animation_finished", self, "_on_animation_finished")
	$Wand/Player.connect("animation_finished", self, "_on_wand_animation_finished")

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
		
		if event.is_action_pressed("p1_down"):
			down_down = true
			print(get_collision_mask_bit(PLATFORM_BIT))
		elif event.is_action_released("p1_down"):
			down_down = false
			set_collision_mask_bit(PLATFORM_BIT, true)
		
		if event.is_action_pressed("p1_use") and is_on_floor():
			casting = true
			caststate = 0
		elif event.is_action_released("p1_use"):
			casting = false
			caststate = 1
			
		if not casting and caststate == 0:
			if event.is_action_pressed("p1_jump") and is_on_floor():
				if down_down:
					print("You should fall now Harry")
					set_collision_mask_bit(PLATFORM_BIT, false)
				else:
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
		$Wand.scale = Vector2(-1, 1)
	elif direction == 1:
		$ASprite.flip_h = false
		$Wand.scale = Vector2(1, 1)
	
	if is_on_floor():
		if motion.x != 0:
			$ASprite.play("Move")
		else:
			_handle_idle_animations(delta)
	else:
		if motion.y < 0:
			$ASprite.play("Jump")
		elif motion.y > 0:
			$ASprite.play("Fall")
			casting = false
			caststate = 0
	
	if casting:
		if caststate == 0:
			caststate = 1
			$Wand/Player.play("WandOut")
	elif not casting and caststate == 1:
		caststate == 2
		$Wand/Player.play("WandIn")
	elif caststate == 0 and $Wand/Player.current_animation != $ASprite.animation:
		if $ASprite.animation == "Breath":
			$Wand/Player.play("Idle")
		elif $ASprite.animation != "Hurt":
			$Wand/Player.play($ASprite.animation)

func _handle_idle_animations(delta):
	if $ASprite.animation != "Breath" and $ASprite.animation != "Idle":
		$ASprite.play("Idle")
	else:
		if idle_time >= idle_breath_time:
			$ASprite.play("Breath")
		else:
			idle_time += delta


func _setWandColor(c):
	$Wand/GFX/Bauble.get_material().set_shader_param("COLOR_A_REPLACEMENT", c)

func _on_animation_finished():
	if $ASprite.animation == "Breath":
		$ASprite.play("Idle")
		idle_time = 0
		idle_breath_time = rand_range(1.0, 4.0)
		
func _on_wand_animation_finished(anim):
	if anim == "WandIn":
		caststate = 0
		if $ASprite.animation == "Breath":
			$Wand/Player.play("Idle")
		if $ASprite.animation != "Hurt":
			$Wand/Player.play($ASprite.animation)




