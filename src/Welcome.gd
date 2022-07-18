extends Node2D

func _ready() -> void:
	randomize();


func _on_Button1p_pressed() -> void:
	get_tree().change_scene("res://src/Arena1p.tscn")


func _on_Button2p_pressed() -> void:
	get_tree().change_scene("res://src/Arena2p.tscn")
