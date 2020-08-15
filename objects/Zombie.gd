extends KinematicBody2D


signal dead(who)

export(float) var shamble_distance = 12
export(float) var shamble_speed = 2
export(Color) var body_color_a = Color(1.0, 1.0, 1.0, 1.0) setget _setColorA
export(Color) var body_color_b = Color(0.0, 0.0, 0.0, 1.0) setget _setColorB


var ready = false
var disappear = false
var life = 3.0
var disappear_time = 5.0
onready var hit_collision_layer = $HitArea.collision_layer
onready var hit_collision_mask = $HitArea.collision_mask

var stun = 0.0
var stun_time = 1.0

var player = null
onready var pos = global_position

var gravity = 192.08
var dir = 1


func _setColorA(c):
	c.a = 1.0
	body_color_a = c
	if ready:
		$Sprite.get_material().set_shader_param("COLOR_A_REPLACEMENT", body_color_a)


func _setColorB(c):
	c.a = 1.0
	body_color_b = c
	if ready:
		$Sprite.get_material().set_shader_param("COLOR_B_REPLACEMENT", body_color_b)


func _enableHitDetection(e = true):
	if e:
		$HitArea.collision_layer = hit_collision_layer
		$HitArea.collision_mask = hit_collision_mask
	else:
		$HitArea.collision_layer = 0
		$HitArea.collision_mask = 0


func _setDead():
	$Fire.lit = false
	$Fire.ignore_particles = true
	# Disable all collisions and detections!
	# We're dead, folks!
	$PlayerDetector.collision_mask = 0
	$EnemyDetector.collision_mask = 0
	#collision_layer = 0
	#collision_mask = 0
	emit_signal("dead")

func _ready():
	ready = true
	if randf() > 0.5:
		dir = -1
	_enableHitDetection(false)

func _process(delta):
	if life > 0.0:
		if dir == 1 and $Sprite.flip_h:
			$Sprite.flip_h = false
		elif dir == -1 and not $Sprite.flip_h:
			$Sprite.flip_h = true


	if disappear:
		disappear_time -= delta
		if disappear_time <= 0.0:
			queue_free()


	if stun > 0.0:
		stun -= delta

	if $Fire.lit:
		life -= delta
		if life <= 0.0:
			_setDead()

	if player != null:
		var pgp = player.global_position
		if pgp.x < global_position.x:
			dir = -1
		elif pgp.x > global_position.x:
			dir = 1
	
	var motion = Vector2(dir * shamble_speed, 0.0)
	if not is_on_floor():
		motion.y += gravity
	if life <= 0.0:
		motion.x = 0.0
	
	motion = move_and_slide(motion, Vector2(0.0, -1.0), true)
	if life > 0.0:
		if motion.x == 0.0:
			dir *= -1
		#elif global_position.distance_to(pos) >= shamble_distance:
	#		dir *= -1
	_handleAnimation()


func _handleAnimation():
	if is_on_floor():
		if $Sprite.animation != "Attack":
			if life < 0.0:
				if $Sprite.animation != "Dead":
					$Sprite.play("Dead")
			elif $Sprite.animation != "Shamble":
				#if $Sprite.animation == "Fall":
				#	pos = global_position
				#	pos.x -= shamble_distance
				$Sprite.play("Shamble")
	elif $Sprite.animation != "Fall":
		$Sprite.play("Fall")


func _on_HitArea_body_entered(body):
	if life > 0.0:
		if player != null and body == player and $Sprite.animation != "Attack" and stun <= 0.0:
			$Sprite.play("Attack")


func _on_PlayerDetector_body_entered(body):
	if player == null:
		player = body
		_enableHitDetection(true)


func _on_PlayerDetector_body_exited(body):
	if body == player:
		player = null
		_enableHitDetection(false)


func _on_Sprite_animation_finished():
	if $Sprite.animation == "Dead":
		disappear = true
	elif player != null and $Sprite.animation == "Attack":
		if player.has_method("takeDamage"):
			player.takeDamage(1.0)
		$Sprite.play("Idle")
		stun = stun_time

func _on_EnemyDetector_body_entered(body):
	dir *= -1




