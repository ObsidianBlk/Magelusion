extends Node


func clearMap():
	var root = get_tree().root.get_node("World")
	if root.has_node("Map"):
		var mapNode = root.get_node("Map")
		if mapNode.has_node("Player_Layer"):
			var plnode = mapNode.get_node("Player_Layer")
			if plnode.has_node("Player"):
				var player = plnode.get_node("Player")
				plnode.remove_child(player)
				root.get_node("Transition_Layer").add_child(player)
			if plnode.has_node("Camera"):
				var camera = plnode.get_node("Camera")
				plnode.remove_child("Camera")
				root.get_node("Transition_Layer").add_child(camera)
		root.remove_child(mapNode)


func loadMap(path : String):
	var root = get_tree().root.get_node("World")
	var tlnode = root.get_node("Transition_Layer")
	var mapNode = load(path)
	if mapNode:
		mapNode = mapNode.instance()
		if mapNode.has_node("Player_Layer") and mapNode.has_node("Camera_Layer") and mapNode.has_node("Player_Start"):
			clearMap()
			mapNode.name = "Map"
			root.add_child(mapNode)
			var player = tlnode.get_node("Player")
			var camera = tlnode.get_node("Camera")
			tlnode.remove_child(player)
			tlnode.remove_child(camera)
			
			var spos = mapNode.get_node("Player_Start").global_position
			mapNode.get_node("Player_Layer").add_child(player)
			mapNode.get_node("Camera_Layer").add_child(camera)
			player.global_position = spos
			camera.global_position = spos
			camera.target_node_path = player.get_path()
			
			if mapNode.has_node("Particle_Container"):
				player.particle_container = mapNode.get_node("Particle_Container").get_path()
			else:
				player.particle_container = mapNode.get_path()
				
			print("Player Path: ", player.get_path())
			print("Camera Path: ", camera.get_path())
		else:
			print ("WARNING: Failed to load map. Missing required node.")
	else:
		print("WARNING: Failed to load map '", path, "'.")




