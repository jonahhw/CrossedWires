extends Node2D

func _ready() -> void:
	randomize();


func _on_Button1p_pressed() -> void:
	get_tree().change_scene("res://Arena1p.tscn")


func _on_Button2p_pressed() -> void:
	get_tree().change_scene("res://Arena2p.tscn")
