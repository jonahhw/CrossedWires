extends Node2D

var speed: float = 1;
var velocity: float = 0;

var canJumpTimer: float = 0;
export var coyoteTime = 0.1;

var actionCooldown: float;

enum InstantAction {
	punch,
	blast
}
enum HoldAction {
	block,
	bolt
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if (event.is_action("p1HoldAct")):
		action1()
	
	if (event.is_action("p1Act2")):
		action2()
	

func _physics_process(delta: float) -> void:
	velocity += Input.get_axis("p1Left", "p1Right");
	
	
func action1():
	pass
	
func action2():
	pass



func _on_Randomize_timeout() -> void:
	pass # Replace with function body.
