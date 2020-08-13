extends Area2D


export(Color) var color = Color(1.0, 1.0, 1.0, 1.0)
export(String) var spell_name = ""


func _ready():
	$Sprite.get_material().set_shader_param("COLOR_A_REPLACEMENT", color)
	$Light2D.color = color


func _on_SpellOrb_body_entered(body):
	if body.is_in_group("Player"):
		var canget = true
		if Database.has("PLAYER_SPELL_" + spell_name):
			canget = not (Database.get("PLAYER_SPELL_" + spell_name) == true)
		if canget:
			Database.set("PLAYER_SPELL_" + spell_name, true)
			queue_free()
