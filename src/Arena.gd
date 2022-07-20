extends Node2D

func p1HealthDepleted(amount: float) -> void:
	if amount <= 0:
		gameOver(2);

func p2HealthDepleted(amount: float) -> void:
	if amount <= 0:
		gameOver(1);

func gameOver(winner: int) -> void:
	$gameOver.visible  = true;
	var format = "Winner:\nPlayer %s!";
	$gameOver/Label.text = format % String(winner);


func _on_Restart_Button_pressed() -> void:
	pass
