extends KinematicBody2D

export var speed: float = 1;
var speedCoeff: float = 1;					# for things like freezing the player and slowing them down
var moveBuffer: Vector2 = Vector2(0, 0);
var velocity: Vector2 = Vector2(0,0);

var health: float = 100;

export var jumpSpeed = 5;
export var coyoteTime = 0.1;				# extra time for jumps to be allowed if not touching ground
var coyoteTimer = 0;
var gravitySpeed = 1;
func gravSpeedCoeff() -> float:
	if isJumpPressed():
		return 0.5;
	else:
		return 1.0;

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

# input functions - to be overridden
func isJumpPressed() -> bool:
	return Input.is_action_pressed("p1Jump");
	
func horizontalAxis() -> float:
	return Input.get_axis("p1Left", "p1Right");
# TODO: move to an inheriting player class along with all other mentions of input
func _input(event: InputEvent) -> void:
	if (event.is_action("p1InstAct")):
		actionInst()
	if (event.is_action("p1HoldAct")):
		actionHold()

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


func _physics_process(delta: float) -> void:
	advanceCooldowns(delta);
	velocity.x *= pow(0.5, delta);
	velocity.x += speedCoeff*speed*horizontalAxis();
	if !is_on_floor():
		velocity.y += gravSpeedCoeff()*gravitySpeed;
	if (isJumpPressed() && (is_on_floor() || (coyoteTimer > 0))):
		velocity.y -= jumpSpeed;
		coyoteTimer = 0;


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
	$CharacterSprite.play("Punch");
	$PunchPlayer.play()
	actionCooldown = 0.5;
	yield($CharacterSprite, "animation_finished")
	

func blast() -> void:
	pass
	
func block() -> void:
	pass
	
func bolt() -> void:
	$CharacterSprite.speed_scale = 0.5;
	$CharacterSprite.play("Punch", true);	# reversed punch animation
	$ChargePlayer.play();
	actionCooldown = 1;
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
