extends Node


func clearMap():
	var transitionLayerNode = get_tree().root.get_node("World/Transition_Layer")
	if not transitionLayerNode:
		print("WARNING: Failed to obtain World/Transition_Layer!!")
		return false
	
	var mapContainerNode = get_tree().root.get_node("World/Map_Container")
	if not mapContainerNode:
		print("WARNING: Failed to obtain World/Map_Container!!")
		return false
	
	var children = mapContainerNode.get_children()
	if children.size() > 1:
		print("WARNING: Map Container contains more than one child!")
	
	if children.size() > 0:
		var mapNode = children[0]
		
		mapNode.disconnect("next_level", self, "_on_next_level")
		mapNode.disconnect("win_game", get_tree().root.get_node("World"), "_on_win_game")
		
		if mapNode.has_node("Player_Layer") and mapNode.has_node("Camera_Layer"):
			if mapNode.has_node("Player_Layer/Player"):
				var player = mapNode.get_node("Player_Layer/Player")
				mapNode.get_node("Player_Layer").remove_child(player)
				transitionLayerNode.add_child(player)
			if mapNode.has_node("Camera_Layer/Camera"):
				var camera = mapNode.get_node("Camera_Layer/Camera")
				camera.current = false
				mapNode.get_node("Camera_Layer").remove_child(camera)
				transitionLayerNode.add_child(camera)
		mapContainerNode.remove_child(mapNode)


func loadMap(path : String):
	var transitionLayerNode = get_tree().root.get_node("World/Transition_Layer")
	if not transitionLayerNode:
		print("WARNING: Failed to obtain World/Transition_Layer!!")
		return false
	
	var mapContainerNode = get_tree().root.get_node("World/Map_Container")
	if not mapContainerNode:
		print("WARNING: Failed to obtain World/Map_Container!!")
		return false
		
	var mapNode = load(path)
	if mapNode:
		mapNode = mapNode.instance()
		if mapNode.has_node("Player_Layer") and mapNode.has_node("Camera_Layer") and mapNode.has_node("Player_Start"):
			clearMap()
			mapContainerNode.add_child(mapNode)
			var player = transitionLayerNode.get_node("Player")
			var camera = transitionLayerNode.get_node("Camera")
			transitionLayerNode.remove_child(player)
			transitionLayerNode.remove_child(camera)
			
			var spos = mapNode.get_node("Player_Start").global_position
			mapNode.get_node("Player_Layer").add_child(player)
			mapNode.get_node("Camera_Layer").add_child(camera)
			player.global_position = spos
			camera.global_position = spos
			camera.target_node_path = player.get_path()
			camera.current = true
			
			if mapNode.has_node("Particle_Container"):
				player.particle_container = mapNode.get_node("Particle_Container").get_path()
			else:
				player.particle_container = mapNode.get_path()
			
			_connectMapSignals(mapNode)
			return true
		else:
			print ("WARNING: Failed to load map. Missing required node.")
	else:
		print("WARNING: Failed to load map '", path, "'.")
	
	return false


func _connectMapSignals(map : Node2D):
	var foundWayOut = false
	for sig in map.get_signal_list():
		if sig["name"] == "next_level":
			map.connect("next_level", self, "_on_next_level")
			foundWayOut = true
		elif sig["name"] == "win_game":
			map.connect("win_game", get_tree().root.get_node("World"), "_on_win_game")
			foundWayOut = true
	if not foundWayOut:
		print("WARNING: Map has no way out!! You stuck bro!!")

func _on_next_level(next):
	loadMap(next)





