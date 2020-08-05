extends Node2D

export(String) var trigger_name = ""
export(PackedScene) var Particle
export(int, 1, 1000, 1) var particle_count = 1
export(int, 1, 1000, 1) var particle_out_min = 1
export(int, 1, 1000, 1) var particle_out_max = 1
export(float, 0.1, 10000.0) var particle_life_min = 0.1
export(float, 0.1, 10000.0) var particle_life_max = 1.0
export(float, 0.1, 1000.0, 0.01) var strength = 500.0
export(float, 0.0, 359.99, 0.01) var angle = 0.0
export(float, 0.0, 1.0) var angle_variance = 0.15

var particle_pool = []
var active_particles = []
var spray_pos = Vector2(0.0, 0.0)
var spray_scale = Vector2(1.0, 1.0)
var spray_active = false
var base_motion = Vector2(0.0, 0.0)

const SPRAY_START_SIGNAL_NAME = "sprayStart"
const SPRAY_END_SIGNAL_NAME = "sprayEnd"
const MOTION_SIGNAL_NAME = "motion"

func start(pos, sc):
	spray_pos = pos
	spray_scale = sc
	spray_active = true

func end():
	spray_active = false

func _ready():
	for i in range(particle_count):
		var p = Particle.instance()
		if p.has_method("isAlive"):
			particle_pool.push_back(Particle.instance())
	if particle_pool.size() != particle_count:
		print ("WARNING: Unable to build complete particle pool.")
	else:
		var foundStart = false
		var foundEnd = false
		var foundMotion = false
		for parentSignal in get_parent().get_signal_list():
			if parentSignal["name"] == SPRAY_START_SIGNAL_NAME:
				foundStart = true
			elif parentSignal["name"] == SPRAY_END_SIGNAL_NAME:
				foundEnd = true
			elif parentSignal["name"] == MOTION_SIGNAL_NAME:
				foundMotion = true
		if foundStart and foundEnd:
			var parent = get_parent()
			parent.connect(SPRAY_START_SIGNAL_NAME, self, "_on_start")
			parent.connect(SPRAY_END_SIGNAL_NAME, self, "_on_end")
			
			if foundMotion:
				parent.connect(MOTION_SIGNAL_NAME, self, "_on_motion")


func _process(delta):
	if spray_active:
		if particle_pool.size() > 0:
			var spawncount = floor(rand_range(particle_out_min, particle_out_max))
			if spawncount > particle_pool.size():
				spawncount = particle_pool.size()
			for i in range(spawncount):
				var p = particle_pool.pop_front()
				p.life = rand_range(particle_life_min, particle_life_max)
				p.global_position = spray_pos
				
				var avar = rand_range(-angle_variance, angle_variance)
				var lv = Vector2(strength, 0.0)
				lv = lv.rotated(deg2rad(angle + (360 * avar))) * spray_scale
				
				p.linear_velocity = base_motion + lv
				get_tree().root.add_child(p)
				
				active_particles.append(p)
	if active_particles.size() > 0:
		if active_particles.size() > 0:
			var rlist = []
			for i in range(active_particles.size()):
				if not active_particles[i].isAlive():
					rlist.append(i)
			if rlist.size() > 0:
				rlist.sort()
				rlist.invert() # We want to remove from the back of the array forward!
				for i in range(rlist.size()):
					var p = active_particles[rlist[i]]
					active_particles.remove(rlist[i])
					get_tree().root.remove_child(p)
					particle_pool.push_back(p)


func _on_start(tname, pos, sc):
	if tname == "" or tname == trigger_name:
		start(pos, sc)

func _on_end():
	end()

func _on_motion(m):
	base_motion = m;
