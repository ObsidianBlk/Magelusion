extends Node


var db = {}

signal valueChanged(name, newval)
signal valueAdded(name, val)
signal valueRemoved(name)

func reset():
	var keys = db.keys()
	for key in keys:
		clear(key)

func get(name : String, default = null):
	if name in db:
		return db[name]
	return default

func set(name : String, value):
	var isnew = false
	if not (name in db):
		isnew = true
	db[name] = value
	if isnew:
		emit_signal("valueAdded", name, value)
	emit_signal("valueChanged", name, value)

func clear(name : String):
	if name in db:
		db.erase(name)
		emit_signal("valueRemoved", name)

func has(name : String):
	return (name in db)


