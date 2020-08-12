extends Camera2D


export(NodePath) var target_node_path
export(float, 0.1, 10.0, 0.01) var lerp_speed = 10.0

func _ready():
	pass # Replace with function body.

func _process(delta):
	var target = get_node(target_node_path)
	if target:
		if target.position != position:
			position = lerp(position, target.position, lerp_speed*delta)
			var fog_offset = position / get_viewport().get_visible_rect().size
			$Fog.get_material().set_shader_param("offset", fog_offset)
