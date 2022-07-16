extends KinematicBody2D

export var speed: float = 1;
var speedCoeff: float = 1;					# for things like freezing the player and slowing them down
var velocity: Vector2 = Vector2(0, 0);		# note that this is distinct from _velocity - this one is more about how much velocity needs to be added.

var health: float = 100;

export var coyoteTime = 0.1;				# extra time for jumps to be allowed if not touching ground
var coyoteTimer = 0;
var gravitySpeed = 1;
var gravSpeedCoeff = 0.5;

var actionCooldown: float = 0;

enum InstantAction {
	punch,
	blast
}
enum HoldAction {
	block,
	bolt
}
var instantAction;
var holdAction;

signal blast_launched;
signal bolt_started;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomizeActions();

func randomizeActions() -> void:
	if (randf() < 0.65):
		instantAction = InstantAction.punch;
	else:
		instantAction = InstantAction.blast;
	
	if (randf() < 0.65):
		holdAction = HoldAction.block;
	else:
		holdAction = HoldAction.bolt;

# TODO: move to an inheriting player class
#func _input(event: InputEvent) -> void:
#	if (event.is_action("p1InstAct")):
#		actionInst()
#	if (event.is_action("p1HoldAct")):
#		actionHold()


func _physics_process(delta: float) -> void:
	advanceCooldowns(delta);
	velocity.x += speedCoeff*speed*Input.get_axis("p1Left", "p1Right");
	var isJumping: bool = false;
	if Input.is_action_pressed("p1Jump") && canJump():
		isJumping = true;
	
func canJump() -> bool:
	
	return true;

func getMoveSpeed(currentVel: Vector2, isJumpingNow: bool) -> Vector2:
	return Vector2();

func advanceCooldowns(delta: float) -> void:
	if is_on_floor():
		coyoteTimer = coyoteTime;
	else:
		coyoteTime -= delta;
	if actionCooldown > 0:
		actionCooldown -= delta;


func actionHold() -> void:
	pass
	
func actionInst() -> void:
	pass
	
func punch() -> void:
	pass

func blast() -> void:
	pass
	
func block() -> void:
	pass
	
func bolt() -> void:
	$CharacterSprite.speed_scale = 0.5;
	$CharacterSprite.play("Punch", true);
	$ChargePlayer.play();
	# freeze player
	yield($ChargePlayer, "finished");
	$BoltPlayer.play();
	# launch bolt
	cancelBolt()

func cancelBolt() -> void:
	$CharacterSprite.speed_scale = 1;
	

func _on_Randomize_timeout() -> void:
	randomizeActions();
	$RandomizeTimer.wait_time = rand_range(5, 8);
	$RandomizeTimer.start();
