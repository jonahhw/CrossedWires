extends "res://Mech.gd"


# overrides of the functions in the base class
func isJumpPressed() -> bool:
	return Input.is_action_pressed("p1Jump");
	
func horizontalAxis() -> float:
	return Input.get_axis("p1Left", "p1Right");


func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("p1InstAct")):
		actionInst()
	if (event.is_action_pressed("p1HoldAct")):
		actionHold()
	if (event.is_action_released("p1HoldAct")):
		actionHoldRelease()
	if (event.is_action_pressed("p1Jump")):
		onJumpPressed()
