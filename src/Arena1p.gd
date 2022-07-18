extends "res://src/Arena.gd"


func _on_Restart_Button_pressed() -> void:
	get_tree().change_scene("res://src/Arena1p.tscn")
