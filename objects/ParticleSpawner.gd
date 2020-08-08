tool
extends Node2D


export(String) var trigger_name = ""
export(bool) var debug = false
export(PackedScene) var spawn
export(NodePath) var trigger_node
export(int, 1, 1000, 1) var spawn_count = 1
export(float) var spawns_per_second = 100.0
export(float, 0.0, 10000.0) var life_min = 0.1
export(float, 0.0, 10000.0) var life_max = 1.0
export(Array, Array, float) var spawn_area = [[0.0, 0.0], [1.0, 1.0]]
export(bool) var single_use = false
export(bool) var auto_spawn = false

var spawn_pool = []
var active_spawns = []
var tospawn_count = 0.0
var spawning = false

const SPAWN_TRIGGER = "spawn"
const SPAWN_END_TRIGGER = "spawn_end"

func start():
	spawning = true

func end():
	spawning = false
	tospawn_count = 0.0

func _ready():
	for i in range(spawn_count):
		var s = spawn.instance()
		if s.has_method("isAlive"):
			spawn_pool.push_back(s)
	if spawn_pool.size() != spawn_count:
		print ("WARNING: Unable to build complete spawn pool.")
	else:
		var foundStart = false
		var foundEnd = false
		var tnode = get_node(trigger_node)
		for sig in tnode.get_signal_list():
			if sig["name"] == SPAWN_TRIGGER:
				foundStart = true
			elif sig["name"] == SPAWN_END_TRIGGER:
				foundEnd = true
		if foundStart and foundEnd:
			tnode.connect(SPAWN_TRIGGER, self, "_on_start")
			tnode.connect(SPAWN_END_TRIGGER, self, "_on_end")
		
		if auto_spawn:
			spawning = true


func _spawn(count):
	if count > spawn_pool.size():
		count = spawn_pool.size()
	for i in range(count):
		var s = spawn_pool.pop_front()
		if life_min <= 0.0 and "immortal" in s:
			s.life = 1.0
			s.immortal = true
		else:
			s.life = rand_range(life_min, life_max)
		var pos = Vector2(
			rand_range(spawn_area[0][0], spawn_area[0][1]),
			rand_range(spawn_area[1][0], spawn_area[1][1])
		)
		s.global_position = global_position + pos
		
		get_tree().root.add_child(s)
		
		active_spawns.append(s)

func _process(delta):
	if debug:
		print("Pool Size: ", spawn_pool.size(), " | Active: ", active_spawns.size())
	if spawning:
		if spawn_pool.size() > 0:
			tospawn_count += spawns_per_second * delta
			if (tospawn_count >= 1.0):
				_spawn(floor(tospawn_count))
				tospawn_count -= floor(tospawn_count)
	if active_spawns.size() > 0:
		var rlist = []
		for i in range(active_spawns.size()):
			if not active_spawns[i].life > 0.0:
				rlist.append(i)
		if rlist.size() > 0:
			rlist.sort()
			rlist.invert() # We want to remove from the back of the array forward!
			for i in range(rlist.size()):
				var s = active_spawns[rlist[i]]
				active_spawns.remove(rlist[i])
				if not single_use:
					get_tree().root.remove_child(s)
					spawn_pool.push_back(s)
				else:
					s.queue_free()


func _on_start():
	start()

func _on_end():
	end()
