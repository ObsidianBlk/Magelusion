extends Node2D

const GAMESTATE_PAUSED = "GAMESTATE_Paused"

export(String) var initial_map = "res://scenes/Demo_Map.tscn"

onready var camera = $Transition_Layer/Camera


func _isMapLoaded():
	return $Map_Container.get_child_count() > 0

func _ready():
	Database.set(GAMESTATE_PAUSED, true)
	Database.connect("valueChanged", self, "_on_database_changed")
	$"UI/Main Menu".visible = true
	$"UI/Main Menu/Start".grab_focus()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		var game_state = Database.get(GAMESTATE_PAUSED)
		Database.set(GAMESTATE_PAUSED, !game_state)

func _on_database_changed(name, value):
	if name == GAMESTATE_PAUSED:
		if value:
			$"UI/Main Menu".visible = true
			$"UI/Main Menu/Start".grab_focus()
		else:
			$"UI/Main Menu".visible = false

func _on_MainMenu_Start_pressed():
	if $"UI/Main Menu".visible:
		if $"UI/Main Menu/Start/Label".text == "Start":
			Database.set(GAMESTATE_PAUSED, false)
			#MapLoader.loadMap("res://scenes/Demo_Map.tscn")
			#MapLoader.loadMap("res://scenes/Maps/Level1.tscn")
			MapLoader.loadMap(initial_map)
			if _isMapLoaded():
				$"UI/Main Menu/Start/Label".text = "Resume"
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
	$"UI/Main Menu/Start/Label".text = "Start"
	$"UI/Main Menu/Background".visible = true
	$"UI/Main Menu".visible = true
	$"UI/Main Menu/Start".grab_focus()


