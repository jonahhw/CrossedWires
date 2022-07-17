extends Area2D

func _ready() -> void:
	$Sprite.flip_h = ((randi() % 2) as bool);
	$Sprite.flip_v = ((randi() % 2) as bool);


func _on_Timer_timeout() -> void:
	queue_free()
