extends Control


signal restart_game

func show():
	visible = true
	$DisplayTime.start()


func _on_DisplayTime_timeout():
	$DisplayTime.stop()
	$Tween.interpolate_property($Image, "modulate:a", 1.0, 0.0, 3.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_Tween_all_completed():
	visible = false
	emit_signal("restart_game")
