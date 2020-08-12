extends Camera2D


export(NodePath) var target_node_path setget _setTargetNode
export(Color) var fog_color setget _setFogColor
export(float, 0.1, 10.0, 0.01) var lerp_speed = 10.0

var target = null


func _setFogColor(fc):
	fog_color = fc
	$Fog.get_material().set_shader_param("color", fc)

func _setTargetNode(tnp):
	target = get_node(tnp)
	if target:
		target_node_path = tnp

func _ready():
	pass # Replace with function body.

func _process(delta):
	if Database.get("GAMESTATE_Paused") == true:
		return

	if target != null:
		if target.position != position:
			position = lerp(position, target.position, lerp_speed*delta)
			var fog_offset = position / get_viewport().get_visible_rect().size
			$Fog.get_material().set_shader_param("offset", fog_offset)
