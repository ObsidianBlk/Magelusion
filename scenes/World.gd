extends Node2D

const GAMESTATE_PAUSED = "GAMESTATE_Paused"
const DIALOG_ENABLED = "DIALOG_ENABLED"
const DIALOG_TUTORIAL_ENABLED = "DIALOG_TUTORIAL_ENABLED"

export(String) var initial_map = "res://scenes/Demo_Map.tscn"

onready var camera = $Transition_Layer/Camera


func _isMapLoaded():
	return $Map_Container.get_child_count() > 0

func _ready():
	Database.set(GAMESTATE_PAUSED, true)
	Database.set(DIALOG_ENABLED, true)
	Database.set(DIALOG_TUTORIAL_ENABLED, true)
	Database.connect("valueChanged", self, "_on_database_changed")
	
	MusicManager.addMusic("MysteryMenu", "res://media/audio/music/MysteryMenu.ogg")
	MusicManager.play("MysteryMenu")
	
	$"UI/Main Menu".visible = true
	$"UI/Main Menu/Buttons/Start".grab_focus()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		var game_state = Database.get(GAMESTATE_PAUSED)
		Database.set(GAMESTATE_PAUSED, !game_state)

func _UpdateAudioServer(name, value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(name), value)

func _on_database_changed(name, value):
	if name == GAMESTATE_PAUSED:
		if value:
			$"UI/Main Menu".visible = true
			$"UI/Main Menu/Buttons/Start".grab_focus()
		else:
			$"UI/Main Menu".visible = false

func _on_MainMenu_Start_pressed():
	if $"UI/Main Menu".visible:
		if $"UI/Main Menu/Buttons/Start/Label".text == "Start":
			Database.set(GAMESTATE_PAUSED, false)
			#MapLoader.loadMap("res://scenes/Demo_Map.tscn")
			#MapLoader.loadMap("res://scenes/Maps/Level2.tscn")
			MapLoader.loadMap(initial_map)
			if _isMapLoaded():
				$"UI/Main Menu/Buttons/Start/Label".text = "Resume"
				$"UI/Main Menu/Background".visible = false
		else:
			Database.set(GAMESTATE_PAUSED, false)


func _on_MainMenu_Quit_pressed():
	if $"UI/Main Menu".visible:
		get_tree().quit()

func _on_win_game():
	$UI/Winner_Screen.show()

func _on_restart_game():
	Database.reset()
	$"UI/Main Menu/Buttons/Start/Label".text = "Start"
	$"UI/Main Menu/Background".visible = true
	MusicManager.play("MysteryMenu")
	$"UI/Main Menu".visible = true
	$"UI/Main Menu/Buttons/Start".grab_focus()

func _on_MasterVolumeSlider_value_changed(value):
	_UpdateAudioServer("Master", value)


func _on_SFXVolumeSlider_value_changed(value):
	_UpdateAudioServer("SFX", value)


func _on_MusicVolumeSlider_value_changed(value):
	_UpdateAudioServer("Music", value)


func _UpdateOptionCTRLValues():
	var val = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	$UI/Options/Controls/VolumeControls/MasterVolume/MasterVolumeSlider.value = val
	val = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	$UI/Options/Controls/VolumeControls/SFXVolume/SFXVolumeSlider.value = val
	val = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	$UI/Options/Controls/VolumeControls/MusicVolume/MusicVolumeSlider.value = val
	
	val = Database.get(DIALOG_ENABLED, false)
	$UI/Options/Controls/DialogOps/DiagAllEnabled.set_pressed(val)
	val = Database.get(DIALOG_TUTORIAL_ENABLED, false)
	$UI/Options/Controls/DialogOps/DiagInstructEnabled.set_pressed(val)

func _on_Options_pressed():
	$"UI/Main Menu".visible = false
	_UpdateOptionCTRLValues()
	$UI/Options.visible = true
	$UI/Options/OptionsDone.grab_focus()


func _on_OptionsDone_pressed():
	$UI/Options.visible = false
	$"UI/Main Menu".visible = true
	$"UI/Main Menu/Buttons/Options".grab_focus()
	

func _on_DiagAllEnabled_toggled(button_pressed):
	var val = $UI/Options/Controls/DialogOps/DiagAllEnabled.is_pressed()
	Database.set(DIALOG_ENABLED, val)


func _on_DiagInstructEnabled_toggled(button_pressed):
	var val = $UI/Options/Controls/DialogOps/DiagInstructEnabled.is_pressed()
	Database.set(DIALOG_TUTORIAL_ENABLED, val)
