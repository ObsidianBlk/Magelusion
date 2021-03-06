extends KinematicBody2D

const PLATFORM_BIT = 1

const SPELL_INFO = [
	{"name":"None", "color": Color(1.0, 1.0, 1.0, 1.0)},
	{"name":"Light", "color": Color(1.0, 1.0, 0.0, 1.0)},
	{"name":"Fire", "color": Color(1.0, 0.0, 0.25, 1.0)},
	{"name":"Water", "color": Color(0.0, 0.25, 1.0, 1.0)}
]
#const COLOR_NO_SPELL = Color(1.0, 1.0, 1.0, 1.0)
#const COLOR_LIGHT_SPELL = Color(1.0, 1.0, 0.0, 1.0)
#const COLOR_FIRE_SPELL = Color(1.0, 0.0, 0.25, 1.0)
#const COLOR_WATER_SPELL = Color(0.0, 0.25, 1.0, 1.0)
#const SPELL_NAMES = ["None", "Light", "Fire", "Water"]
const WAND_LIGHT_SCALE_MIN = 0.2
const WAND_LIGHT_SCALE_MAX = 1.0

const MAX_HURT_TIME = 0.5
const MAX_INVULNERABLE_TIME = 3.0
const MAX_USING_TIME = 0.5

export (NodePath) var particle_container setget _setParticleContainer

var gravity = 192.08
var friction = 0.35
var speed = 96
var acceleration = 0.75
var motion = Vector2(0, 0)
var jump_force_multiplier = 0.5
var jumping = false
var caststate = 0
var using_time = 0.0

var push_vector = Vector2(0.0, 0.0)

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

enum SPELL {NONE=0, LIGHT=1, FIRE=2, WATER=3}
var spell_available = [true, false, false, false]
var spell_mode = SPELL.NONE

var print_delay = 1.0


signal death(who)
signal hurt(who)
signal sprayStart(trigger, pos, sc)
signal sprayUpdate(pos, sc)
signal sprayEnd
signal activate
signal motion(m)



func _setWandColor(c):
	$Wand/GFX/Bauble.get_material().set_shader_param("COLOR_A_REPLACEMENT", c)

func _scrollMode(dir):
	var cm = spell_mode
	if dir > 0:
		cm = _nextAvailableSpell()
	elif dir < 0:
		cm = _prevAvailableSpell()
	if cm != spell_mode:
		_selectMode(cm)

func _nextAvailableSpell():
	var c = spell_mode + 1
	while c <= SPELL.WATER:
		if spell_available[c]:
			return c
		c = c + 1
	c = 0
	while c < spell_mode:
		if spell_available[c]:
			return c
		c = c + 1
	return spell_mode

func _prevAvailableSpell():
	var c = spell_mode - 1
	while c >= 0:
		if spell_available[c]:
			return c
		c = c - 1
	c = SPELL.WATER
	while c > spell_mode:
		if spell_available[c]:
			return c
		c = c - 1
	return spell_mode

func _selectMode(m):
	var osm = spell_mode
	spell_mode = m
	var color = SPELL_INFO[spell_mode].color
	if spell_mode == SPELL.NONE:
		$Wand/GFX/Light2D.enabled = false
		_setWandColor(color)
	else:
		$Wand/GFX/Light2D.color = color
		$Wand/GFX/Light2D.enabled = true
		_setWandColor(color)
	
	if spell_mode != osm:
		_stopCasting()

func _playCastingSound(play:bool = true):
	if play:
		$Wand/WandAudioCtrl.play(SPELL_INFO[spell_mode].name)
	else:
		$Wand/WandAudioCtrl.stop()

func _startCasting():
	if caststate != 1:
		caststate = 1
		$Wand/Player.play("WandOut")

func _stopCasting():
	if caststate == 1:
		caststate = 2
		$Wand/Player.play("WandIn")
		_handleSpellEffect(false)


func _handleSpellEffect(enable):
	if enable:
		match spell_mode:
			SPELL.NONE:
				pass
			SPELL.LIGHT:
				$Wand/GFX/Tween.interpolate_property(
					$Wand/GFX/Light2D, "texture_scale",
					$Wand/GFX/Light2D.texture_scale, WAND_LIGHT_SCALE_MAX,
					0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
				)
				$Wand/GFX/Tween.start()
			SPELL.FIRE:
				_playCastingSound()
				emit_signal("sprayStart", SPELL_INFO[spell_mode].name, $Wand/GFX/SprayPoint.global_position, $Wand.scale)
			SPELL.WATER:
				_playCastingSound()
				emit_signal("sprayStart", SPELL_INFO[spell_mode].name, $Wand/GFX/SprayPoint.global_position, $Wand.scale)
	else:
		match spell_mode:
			SPELL.NONE:
				pass
			SPELL.LIGHT:
				$Wand/GFX/Tween.interpolate_property(
					$Wand/GFX/Light2D, "texture_scale",
					$Wand/GFX/Light2D.texture_scale, WAND_LIGHT_SCALE_MIN,
					0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
				)
				$Wand/GFX/Tween.start()
			SPELL.FIRE:
				_playCastingSound(false)
				emit_signal("sprayEnd")
			SPELL.WATER:
				_playCastingSound(false)
				emit_signal("sprayEnd")



func _setParticleContainer(pc):
	particle_container = pc
	_connectParticleContainer()

func _connectParticleContainer():
	var n = get_node(particle_container)
	if n:
		var npath = n.get_path()
		$Sprayer_Fire.particle_container = npath
		$Sprayer_Water.particle_container = npath
	else:
		print("WARNING: Player particle container, '", particle_container, "', not found!")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Adding the player audio samples...
	$Wand/WandAudioCtrl.addSample("Fire", "res://media/audio/sfx/fire-loop1.wav")
	$Wand/WandAudioCtrl.addSample("Water", "res://media/audio/sfx/fr-water.wav")
	
	$AudioCtrl.addSample("JumpLand", "res://media/audio/sfx/jumpland.wav")
	
	# Connecting to the game database to watch for special variables...
	Database.connect("valueChanged", self, "_on_db_change")
	Database.connect("valueRemoved", self, "_on_db_removed")
	
	# Now the rest of it all!
	_connectParticleContainer()
	
	$ASprite.connect("animation_finished", self, "_on_animation_finished")
	$Wand/Player.connect("animation_finished", self, "_on_wand_animation_finished")



func _input(event):
	if Database.get("GAMESTATE_Paused") == true or Database.get("GAMESTATE_Dialog") == true:
		return

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
		elif event.is_action_released("p1_down"):
			down_down = false
			set_collision_mask_bit(PLATFORM_BIT, true)
		
		if caststate == 0:
			if event.is_action_pressed("p1_select_fire") and spell_available[SPELL.FIRE]:
				_selectMode(SPELL.FIRE)
			elif event.is_action_pressed("p1_select_water") and spell_available[SPELL.WATER]:
				_selectMode(SPELL.WATER)
			elif event.is_action_pressed("p1_select_light") and spell_available[SPELL.LIGHT]:
				_selectMode(SPELL.LIGHT)
			elif event.is_action_pressed("p1_next_spell"):
				_scrollMode(1)
			elif event.is_action_pressed("p1_prev_spell"):
				_scrollMode(-1)
			
		
		if event.is_action_pressed("p1_cast"):
			_startCasting()
		elif event.is_action_released("p1_cast"):
			_stopCasting()
		
		
		if is_on_floor():
			if event.is_action_pressed("p1_use") and caststate == 0:
				motion.x = 0.0
				using_time = MAX_USING_TIME
			elif event.is_action_pressed("p1_jump"):
				if down_down:
					set_collision_mask_bit(PLATFORM_BIT, false)
				else:
					jumping = true

func _physics_process(delta):
	if Database.get("GAMESTATE_Paused") == true or Database.get("GAMESTATE_Dialog") == true:
		if Database.get("GAMESTATE_Dialog") == true:
			left_down = false
			right_down = false
			down_down = false
			_stopCasting()
			set_collision_mask_bit(PLATFORM_BIT, true)
			motion = Vector2.ZERO
		return

	if damage > 0.0:
		damage = 0.0 # TODO: Actually subtract this from some form of life tracker!
		hurt = true
		_stopCasting()
		emit_signal("hurt", self)
	
	if invulnerable_timer > 0.0:
		invulnerable_timer -= delta
	
	if using_time > 0.0:
		using_time -= delta
		if using_time <= 0.0:
			emit_signal("activate")
			using_time = 0.0
	
	if not hurt:
		var inAir = not is_on_floor()
		if inAir:
			motion.y = clamp(motion.y + (gravity * delta), -1000, gravity * 2)
	
		var dir = 0
		if left_down:
			dir -= 1
		if right_down:
			dir += 1
		if dir != 0 and using_time <= 0.0:
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
		if inAir and is_on_floor():
			$AudioCtrl.play("JumpLand")
		emit_signal("motion", Vector2(motion.x, 0.0))
		if caststate == 1:
			emit_signal("sprayUpdate", $Wand/GFX/SprayPoint.global_position, $Wand.scale)
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
		elif using_time > 0.0:
			if $ASprite.animation != "Use":
				$ASprite.play("Use")
		else:
			_handle_idle_animations(delta)
	else:
		if motion.y < 0:
			$ASprite.play("Jump")
		elif motion.y > 0:
			$ASprite.play("Fall")
	
	if caststate == 0 and $Wand/Player.current_animation != $ASprite.animation:
		if $ASprite.animation == "Breath":
			$Wand/Player.play("Idle")
		elif $ASprite.animation != "Hurt" and $ASprite.animation != "Use":
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
		_handleSpellEffect(true)
	if anim == "WandIn":
		caststate = 0
		if $ASprite.animation == "Breath":
			$Wand/Player.play("Idle")
		if $ASprite.animation != "Hurt":
			$Wand/Player.play($ASprite.animation)

func _on_db_removed(name):
	match name:
		"PLAYER_SPELL_Light":
			spell_available[SPELL.LIGHT] = false
			if spell_mode == SPELL.LIGHT:
				_selectMode(SPELL.NONE)
		"PLAYER_SPELL_Fire":
			spell_available[SPELL.FIRE] = false
			if spell_mode == SPELL.FIRE:
				_selectMode(SPELL.NONE)
		"PLAYER_SPELL_Water":
			spell_available[SPELL.WATER] = false
			if spell_mode == SPELL.WATER:
				_selectMode(SPELL.NONE)

func _on_db_change(name, val):
	match name:
		"PLAYER_SPELL_Light":
			if val == true:
				spell_available[SPELL.LIGHT] = true
				_selectMode(SPELL.LIGHT)
			else:
				spell_available[SPELL.LIGHT] = false
				if spell_mode == SPELL.LIGHT:
					_selectMode(SPELL.NONE)
		"PLAYER_SPELL_Fire":
			if val == true:
				spell_available[SPELL.FIRE] = true
				_selectMode(SPELL.FIRE)
			else:
				spell_available[SPELL.FIRE] = false
				if spell_mode == SPELL.FIRE:
					_selectMode(SPELL.NONE)
		"PLAYER_SPELL_Water":
			if val == true:
				spell_available[SPELL.WATER] = true
				_selectMode(SPELL.WATER)
			else:
				spell_available[SPELL.WATER] = false
				if spell_mode == SPELL.WATER:
					_selectMode(SPELL.NONE)


func takeDamage(amount):
	if amount > 0.0 and not hurt and invulnerable_timer <= 0.0:
		damage += amount

func push(vpush):
	motion += vpush
