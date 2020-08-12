extends Node


var db = {}


func get(name : String):
	if name in db:
		return db[name]
	return null

func set(name : String, value):
	db[name] = value

func clear(name : String):
	if name in db:
		db.erase(name)

func has(name : String):
	return (name in db)


