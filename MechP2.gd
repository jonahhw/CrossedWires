extends "res://Mech.gd"

# overrides of the functions in the base class
func isJumpPressed() -> bool:
	return Input.is_action_pressed("p2Jump");
	
func horizontalAxis() -> float:
	return Input.get_axis("p2Left", "p2Right");


func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("p2InstAct")):
		actionInst()
	if (event.is_action_pressed("p2HoldAct")):
		actionHold()
	if (event.is_action_released("p2HoldAct")):
		actionHoldRelease()
	if (event.is_action_pressed("p2Jump")):
		onJumpPressed()
