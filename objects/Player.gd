extends KinematicBody2D

const COLOR_NO_SPELL = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_LIGHT_SPELL = Color(1.0, 1.0, 0.0, 1.0)
const COLOR_FIRE_SPELL = Color(1.0, 0.0, 0.25, 1.0)
const COLOR_WATER_SPELL = Color(0.0, 0.25, 1.0, 1.0)

const PLATFORM_BIT = 1

const MAX_HURT_TIME = 0.5
const MAX_INVULNERABLE_TIME = 3.0

export (NodePath) var particle_container

var gravity = 192.08
var friction = 0.35
var speed = 96
var acceleration = 0.75
var motion = Vector2(0, 0)
var jump_force_multiplier = 0.5
var jumping = false
var casting = false
var caststate = 0

var damage = 0.0
var hurt_timer = MAX_HURT_TIME
var hurt = false
var invulnerable_timer = 0.0

var last_mouse_pos = null

var left_down = false
var right_down = false
var down_down = false

var idle_time = 0.0
var idle_breath_time = rand_range(1.0, 4.0)

var spray_mode = "NONE"

var print_delay = 1.0


signal death(who)
signal hurt(who)
signal sprayStart(trigger, pos, sc)
signal sprayEnd
signal motion(m)



func _setWandColor(c):
	$Wand/GFX/Bauble.get_material().set_shader_param("COLOR_A_REPLACEMENT", c)

func _selectMode(m):
	var osm = spray_mode
	if m == "Fire":
		spray_mode = "Fire"
		$Wand/GFX/Light2D.color = COLOR_FIRE_SPELL
		$Wand/GFX/Light2D.enabled = true
		_setWandColor(COLOR_FIRE_SPELL)
	elif m == "Water":
		$Wand/GFX/Light2D.color = COLOR_WATER_SPELL
		$Wand/GFX/Light2D.enabled = true
		spray_mode = "Water"
		_setWandColor(COLOR_WATER_SPELL)
	
	if spray_mode != osm:
		_stopCasting()

func _startCasting():
	if not casting:
		casting = true
		caststate = 0

func _stopCasting():
	if casting:
		casting = false
		caststate = 3
		emit_signal("sprayEnd")

# Called when the node enters the scene tree for the first time.
func _ready():
	var n = get_node(particle_container)
	var npath = n.get_path()
	$Sprayer_Fire.particle_container = npath
	$Sprayer_Water.particle_container = npath
	
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
		
		if event.is_action_pressed("p1_select_fire"):
			_selectMode("Fire")
		elif event.is_action_pressed("p1_select_water"):
			_selectMode("Water")
		
		if event.is_action_pressed("p1_cast"):
			_startCasting()
		elif event.is_action_released("p1_cast"):
			_stopCasting()
			
		if event.is_action_pressed("p1_jump") and is_on_floor():
			if down_down:
				set_collision_mask_bit(PLATFORM_BIT, false)
			else:
				jumping = true

func _physics_process(delta):
	if damage > 0.0:
		damage = 0.0 # TODO: Actually subtract this from some form of life tracker!
		hurt = true
		_stopCasting()
		emit_signal("hurt", self)
	
	if invulnerable_timer > 0.0:
		invulnerable_timer -= delta
	
	if not hurt:
		motion.y += (gravity * delta)
	
		var dir = 0
		if left_down:
			dir -= 1
		if right_down:
			dir += 1
		if dir != 0:
			motion.x = lerp(motion.x, (dir * speed), acceleration * delta)
		elif motion.x != 0.0:
			motion.x = lerp(motion.x, 0, friction)
			if abs(motion.x) < 0.01:
				motion.x = 0.0
		
		var snap_vec = Vector2(0, 1)
		if jumping:
			snap_vec = Vector2.ZERO
			jumping = false
			motion.y -= (gravity * jump_force_multiplier)
	
		_handle_animations(delta, dir)
		motion = move_and_slide_with_snap(motion, snap_vec, Vector2(0, -1), false, 4, 0.785398, true)
		emit_signal("motion", Vector2(motion.x, 0.0))
		if caststate == 2:
			emit_signal("sprayStart", spray_mode, $Wand/GFX/SprayPoint.global_position, $Wand.scale)
	else:
		# TODO: Do something with dmg!!
		hurt_timer -= delta
		if hurt_timer <= 0.0:
			hurt_timer = MAX_HURT_TIME
			hurt = false
			invulnerable_timer = MAX_INVULNERABLE_TIME
		_handle_animations(delta, 0)
		


func _handle_animations(delta, direction):
	if direction == -1:
		$ASprite.flip_h = true
		$Wand.scale = Vector2(-1, 1)
	elif direction == 1:
		$ASprite.flip_h = false
		$Wand.scale = Vector2(1, 1)
	
	if hurt and $ASprite.animation != "Hurt":
		$ASprite.animation = "Hurt"
		$Wand.visible = false
	elif not hurt and not $Wand.visible:
		$Wand.visible = true
	
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
	
	if casting:
		if caststate == 0:
			caststate = 1
			$Wand/Player.play("WandOut")
	elif not casting and caststate > 1:
		caststate == 3
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



func _on_animation_finished():
	if $ASprite.animation == "Breath":
		$ASprite.play("Idle")
		idle_time = 0
		idle_breath_time = rand_range(1.0, 4.0)
		
func _on_wand_animation_finished(anim):
	if anim == "WandOut":
		caststate = 2
		emit_signal("sprayStart", spray_mode, $Wand/GFX/SprayPoint.global_position, $Wand.scale)
	if anim == "WandIn":
		caststate = 0
		if $ASprite.animation == "Breath":
			$Wand/Player.play("Idle")
		if $ASprite.animation != "Hurt":
			$Wand/Player.play($ASprite.animation)


func takeDamage(amount):
	if amount > 0.0 and not hurt and invulnerable_timer <= 0.0:
		damage += amount
