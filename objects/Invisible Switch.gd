extends Area2D
tool

const FIRE_LIT_SIGNAL = "fireLit"
const FIRE_UNLIT_SIGNAL = "fireUnlit"

export(Array, String) var trigger_groups
export(Array, int) var trigger_count
export(Array, NodePath) var fire_triggers setget _setFireTriggers
export(bool) var single_trigger = false
export(bool) var invert_trigger = false

signal switchOn
signal switchOff

enum STATE{UP, DOWN}

var fires = []
var bodies = {}
var no_trigger = false
var triggered = false
var ready = false


func _setFireTriggers(fl):
	if not ready:
		fire_triggers = fl
	else:
		_disconnectAllFireTriggers()
		fire_triggers = fl
		_connectAllFireTriggers()


func _ready():
	ready = true
	_connectAllFireTriggers()


func _connectAllFireTriggers():
	if fire_triggers.size() > 0:
		for firepath in fire_triggers:
			if firepath != null:
				var fire = get_node(firepath)
				if fire:
					_connectFireTrigger(fire)

func _disconnectAllFireTriggers():
	if fire_triggers.size() > 0:
		for firepath in fire_triggers:
			if firepath != null:
				var fire = get_node(firepath)
				if fire:
					_disconnectFireTrigger(fire)

func _connectFireTrigger(fire : Node2D):
	if not fire.has_method("is_lit"):
		return # If is_lit() is not part of the object, it's not the correct object.
		
	var foundLit = false
	var foundUnlit = false
	for sig in fire.get_signal_list():
		if sig["name"] == FIRE_LIT_SIGNAL:
			foundLit = true
		elif sig["name"] == FIRE_UNLIT_SIGNAL:
			foundUnlit = true
	if foundLit and foundUnlit:
		fire.connect(FIRE_LIT_SIGNAL, self, "_on_fire_lit")
		fire.connect(FIRE_UNLIT_SIGNAL, self, "_on_fire_unlit")
		var fi = _getFireIndex(fire)
		if fi < 0:
			fires.append({
				"name": fire.name,
				"lit": fire.is_lit()
			})

func _disconnectFireTrigger(fire : Node2D):
	fire.disconnect(FIRE_LIT_SIGNAL, self, "_on_fire_lit")
	fire.disconnect(FIRE_UNLIT_SIGNAL, self, "_on_fire_unlit")
	var fi = _getFireIndex(fire)
	if fi >= 0:
		fires.remove(fi)

func _getFireIndex(fire : Node2D):
	if fires.size() > 0:
		for i in range(fires.size()):
			if fires[i].name == fire.name:
				return i
	return -1

func _allFiresLit(invert:bool = false):
	if fires.size() > 0:
		for info in fires:
			if not info.lit:
				return invert
		return not invert
	return invert

func _addBody(group : String, body : Node2D):
	if not (group in bodies):
		bodies[group] = []
	bodies[group].append(body)
	return bodies[group].size()

func _removeBody(group : String, body : Node2D):
	if group in bodies:
		for i in range(bodies[group].size()):
			if bodies[group][i] == body:
				bodies[group].remove(i)
				return true
	return false

func _bodiesInGroup(group : String):
	if group in bodies:
		return bodies[group].size()
	return 0

func _isTriggered():
	if trigger_groups.size() > 0:
		for i in range(trigger_groups.size()):
			var tcount = _getTriggerCountForGroup(trigger_groups[i])
			if tcount > 0 and _bodiesInGroup(trigger_groups[i]):
				return true
	return false

func _getTriggerGroupIndex(group : String):
	if trigger_groups.size() > 0 and group != "":
		for i in range(trigger_groups.size()):
			if trigger_groups[i] == group:
				return i
	return -1

func _getTriggerCountForGroup(group : String):
	var gi = _getTriggerGroupIndex(group)
	if gi >= 0:
		if trigger_count.size() > gi:
			return trigger_count[gi]
	return 0

func _getTriggerGroup(obj : Node2D):
	if trigger_groups.size() > 0:
		for trigger_group in trigger_groups:
			if obj.is_in_group(trigger_group):
				return trigger_group
	return ""


func _emitSwitch(on = true):
	if invert_trigger:
		if on:
			emit_signal("switchOff")
		else:
			emit_signal("switchOn")
	else:
		if on:
			emit_signal("switchOn")
		else:
			emit_signal("switchOff")

func _on_body_entered(body):
	if no_trigger:
		return

	var group = _getTriggerGroup(body)
	if group != "":
		var tcount = _getTriggerCountForGroup(group)
		if tcount > 0:
			_addBody(group, body)
			if _isTriggered() and not triggered:
				triggered = true
				_emitSwitch()
				if single_trigger:
					no_trigger = true


func _on_body_exited(body):
	var group = _getTriggerGroup(body)
	if group != "":
		if _removeBody(group, body):
			if not _isTriggered() and triggered:
				triggered = false
				_emitSwitch(false)


func _on_fire_lit(fire):
	var fi = _getFireIndex(fire)
	if fi >= 0:
		fires[fi].lit = true
		if _allFiresLit(invert_trigger):
			_emitSwitch()
		

func _on_fire_unlit(fire):
	var fi = _getFireIndex(fire)
	if fi >= 0:
		var all_lit = _allFiresLit(invert_trigger) # This NEEDS to come first!
		fires[fi].lit = false
		if all_lit:
			_emitSwitch(false)



