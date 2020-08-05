extends Node2D
tool

var time = 0
export(float, 0.1, 10.0, 0.01) var base_energy = 1.0
export(float, 0.1, 10.0, 0.01) var base_scale = 1.0

func _process(delta):
	time += delta * 75
	var n = ($fire.get_material().get_shader_param("noise") as NoiseTexture)
	var offset = n.noise.get_noise_1d(time)
	$Light2D.scale = Vector2(base_scale + offset/3, base_scale + offset/3)
	$Light2D.energy = base_energy + offset/3
	$"Light2D-FogMask".scale = $Light2D.scale
	$"Light2D-FogMask".energy = $Light2D.energy
