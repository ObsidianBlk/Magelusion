extends VBoxContainer
tool


export (Color) var focus_color = Color(1.0, 1.0, 1.0, 1.0)
export (Color) var idle_color = Color(0.5, 0.5, 0.5, 1.0)


func _ready():
	$VolumeControls/MasterVolume/Label.set("custom_colors/font_color", idle_color);
	$VolumeControls/SFXVolume/Label.set("custom_colors/font_color", idle_color);
	$VolumeControls/MusicVolume/Label.set("custom_colors/font_color", idle_color);


func _on_MasterVolumeSlider_focus_entered():
	$VolumeControls/MasterVolume/Label.set("custom_colors/font_color", focus_color);


func _on_MasterVolumeSlider_focus_exited():
	$VolumeControls/MasterVolume/Label.set("custom_colors/font_color", idle_color);


func _on_SFXVolumeSlider_focus_entered():
	$VolumeControls/SFXVolume/Label.set("custom_colors/font_color", focus_color);


func _on_SFXVolumeSlider_focus_exited():
	$VolumeControls/SFXVolume/Label.set("custom_colors/font_color", idle_color);


func _on_MusicVolumeSlider_focus_entered():
	$VolumeControls/MusicVolume/Label.set("custom_colors/font_color", focus_color);


func _on_MusicVolumeSlider_focus_exited():
	$VolumeControls/MusicVolume/Label.set("custom_colors/font_color", idle_color);
