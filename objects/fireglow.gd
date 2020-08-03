extends Sprite
tool

var time = 0

func _process(delta):
	time += delta * 75
	var n = (get_material().get_shader_param("noise") as NoiseTexture)
	var offset = n.noise.get_noise_1d(time)
	$Light2D.scale = Vector2(1.5 + offset/3, 1.5 + offset/3)
	$Light2D.energy = 1.0 + offset/3
