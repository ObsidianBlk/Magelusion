extends Node2D

const GAMESTATE_PAUSED = "GAMESTATE_Paused"

onready var camera = $Transition_Layer/Camera


func _isMapLoaded():
	return $Map_Container.get_child_count() > 0

func _ready():
	Database.set(GAMESTATE_PAUSED, true)
	Database.connect("valueChanged", self, "_on_database_changed")
	$"UI/Main Menu".visible = true

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		var game_state = Database.get(GAMESTATE_PAUSED)
		Database.set(GAMESTATE_PAUSED, !game_state)

func _on_database_changed(name, value):
	if name == GAMESTATE_PAUSED:
		if value:
			$"UI/Main Menu".visible = true
		else:
			$"UI/Main Menu".visible = false

func _on_MainMenu_Start_pressed():
	if $"UI/Main Menu".visible:
		if $"UI/Main Menu/Start/Label".text == "Start":
			Database.set(GAMESTATE_PAUSED, false)
			MapLoader.loadMap("res://scenes/Demo_Map.tscn")
			if _isMapLoaded():
				$"UI/Main Menu/Start/Label".text = "Resume"
				$"UI/Main Menu/Background".visible = false
		else:
			Database.set(GAMESTATE_PAUSED, false)


func _on_MainMenu_Quit_pressed():
	if $"UI/Main Menu".visible:
		get_tree().quit()





