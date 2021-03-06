extends Node2D

export(PackedScene) var BloodParticle
export(int) var BloodParticleCount = 15
export(float) var BloodVelocity = 500.0

const SPLATTER_SIGNAL_NAME = "death"
const SPLATTER_HURT_SIGNAL_NAME = "hurt"

var rnd = RandomNumberGenerator.new()
var hbv = 250.0

func _ready():
	for parentSignal in get_parent().get_signal_list():
		if parentSignal["name"] == SPLATTER_SIGNAL_NAME:
			get_parent().connect(SPLATTER_SIGNAL_NAME, self, "_on_parent_death")
		elif parentSignal["name"] == SPLATTER_HURT_SIGNAL_NAME:
			get_parent().connect(SPLATTER_HURT_SIGNAL_NAME, self, "_on_parent_hurt")
	rnd.randomize()
	hbv = BloodVelocity * 0.5

func _on_parent_death(who):
	splatter()

func _on_parent_hurt(who):
	splatter(floor(BloodParticleCount * 0.5))

func _getRandLinearVelocity():
	var lvx = rnd.randf_range(-hbv, hbv)
	if lvx < 0:
		lvx += -hbv
	else:
		lvx += hbv
	
	var lvy = rnd.randf_range(-hbv, hbv)
	if lvy < 0:
		lvy += -hbv
	else:
		lvy += hbv
	
	return Vector2(lvx, lvy)

func splatter(spawnCount := 0):
	if spawnCount <= 0:
		spawnCount = BloodParticleCount
	
	for i in range(spawnCount):
		var sp = BloodParticle.instance()
		get_tree().root.add_child(sp);
		sp.global_position = global_position
		var rlv = _getRandLinearVelocity()
		sp.linear_velocity = rlv
	
	
	
	
