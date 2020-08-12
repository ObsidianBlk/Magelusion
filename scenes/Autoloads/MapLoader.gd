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
		
		if mapNode.has_node("Player_Layer"):
			var plnode = mapNode.get_node("Player_Layer")
			if plnode.has_node("Player"):
				var player = plnode.get_node("Player")
				plnode.remove_child(player)
				transitionLayerNode.add_child(player)
			if plnode.has_node("Camera"):
				var camera = plnode.get_node("Camera")
				plnode.remove_child("Camera")
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
			mapNode.name = "Map"
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
			
			if mapNode.has_node("Particle_Container"):
				player.particle_container = mapNode.get_node("Particle_Container").get_path()
			else:
				player.particle_container = mapNode.get_path()
			
			return true
		else:
			print ("WARNING: Failed to load map. Missing required node.")
	else:
		print("WARNING: Failed to load map '", path, "'.")
	
	return false




