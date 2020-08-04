extends Node2D

export(PackedScene) var Particle
export(int, 1, 1000, 1) var particle_count = 1
export(int, 1, 1000, 1) var particle_out_min = 1
export(int, 1, 1000, 1) var particle_out_max = 1
export(float, 0.1, 100.0) var particle_life_min = 0.1
export(float, 0.1, 100.0) var particle_life_max = 1.0
export(float, 0.1, 1000.0, 0.01) var strength = 500.0
export(float, 0.0, 359.99, 0.01) var angle = 0.0
export(float, 0.0, 1.0) var angle_variance = 0.15

var particle_pool = []
var active_particles = []
var spray_pos = Vector2(0.0, 0.0)
var spray_scale = Vector2(1.0, 1.0)
var spray_active = false

const SPRAY_START_SIGNAL_NAME = "sprayStart"
const SPRAY_END_SIGNAL_NAME = "sprayEnd"

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
	if particle_pool.count != particle_count:
		print ("WARNING: Unable to build complete particle pool.")
	else:
		var foundStart = false
		var foundEnd = false
		for parentSignal in get_parent().get_signal_list():
			if parentSignal["name"] == SPRAY_START_SIGNAL_NAME:
				foundStart = true
			elif parentSignal["name"] == SPRAY_END_SIGNAL_NAME:
				foundEnd = true
		if foundStart and foundEnd:
			get_parent().connect(SPRAY_START_SIGNAL_NAME, self, "_on_start")
			get_parent().connect(SPRAY_END_SIGNAL_NAME, self, "_on_end")


func _process(delta):
	if spray_active:
		if particle_pool.count > 0:
			var spawncount = floor(rand_range(particle_out_min, particle_out_max))
			if spawncount > particle_pool.count:
				spawncount = particle_pool.count
			for i in range(spawncount):
				var p = particle_pool.pop_front()
				p.life = rand_range(particle_life_min, particle_life_max)
				p.global_position = spray_pos
				
				var avar = rand_range(-angle_variance, angle_variance)
				var lv = Vector2(strength, 0.0)
				lv = lv.rotated(deg2rad(angle + (360 * avar))) * spray_scale
				
				p.linear_velocity = lv
				get_tree().root.add_child(p)
				
				active_particles.append(p)
		if active_particles.count > 0:
			var rlist = []
			for i in range(active_particles.count):
				if not active_particles[i].isAlive():
					rlist.append(i)
			for i in range(rlist.count):
				var pl = active_particles.slice(rlist[i], 1)
				get_tree().root.remove_child(pl[0])
				particle_pool.push_back(pl[0])


func _on_start(pos, sc):
	start(pos, sc)

func _on_end():
	end()
