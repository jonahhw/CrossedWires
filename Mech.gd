extends KinematicBody2D

var health: float = 100;

var moveBuffer: Vector2 = Vector2(0, 0);
var velocity: Vector2 = Vector2(0,0);

export var accelerationX: float = 10;
export var maxSpeedX: float = 40;
export var friction: float = 10;

export var jumpSpeed = 400;
export var coyoteTime = 0.1;				# extra time for jumps to be allowed if not touching ground
var coyoteTimer = 0;						# keeps track of time since fallen off a ledge
export var jumpBufferTime = 0.1;					# jump buffering
var jumpBufferTimer = 0;							# keeps track of time since pressing the jump button for jump buffering
export var gravitySpeed = 50;
export var maxSpeedY = 400;
func gravSpeedCoeff() -> float:
	if isJumpPressed():
		return 0.4;
	else:
		return 1.0;

var actionCooldown: float = 0;

var shieldActive: bool = false;

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
	if (event.is_action_pressed("p1InstAct")):
		actionInst()
	if (event.is_action_pressed("p1HoldAct")):
		actionHold()
	if (event.is_action_released("p1HoldAct")):
		actionHoldRelease()
	if (event.is_action_pressed("p1Jump")):
		onJumpPressed()

func onJumpPressed() -> void:
	jumpBufferTimer = jumpBufferTime;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomizeActions();
	$CharacterSprite.play("Idle")

func randomizeActions() -> void:
	if (randf() < 0.65):
		instantAction = InstantAction.punch;
	else:
		instantAction = InstantAction.blast;
	
	if (randf() < 0.65):
		holdAction = HoldAction.block;
	else:
		holdAction = HoldAction.bolt;
	$DicePlayer.play();

func _process(delta: float) -> void:
	if actionCooldown <= 0:
		if abs(velocity.x) > 1:
			$CharacterSprite.speed_scale = abs(velocity.x)/35
			if is_on_floor():
				$CharacterSprite.play("Walk");
			else:
				$CharacterSprite.playing = false;
			if velocity.x < 0:
				$CharacterSprite.flip_h = true;
			else:
				$CharacterSprite.flip_h = false;
		else:
			$CharacterSprite.play("Idle");
			$CharacterSprite.speed_scale = 1;
	elif ($CharacterSprite.get_animation() != "Punch"):
		$CharacterSprite.playing = false;

func _physics_process(delta: float) -> void:
	advanceCooldowns(delta);
	if abs(velocity.x) < friction*delta:
		velocity.x = 0;
	else:
		 velocity.x -= delta*sign(velocity.x)*friction;
	velocity.y += delta*gravSpeedCoeff()*gravitySpeed;
	if !(actionCooldown > 0):
		velocity.x += delta*accelerationX*horizontalAxis();
		if ((isJumpPressed() && (jumpBufferTimer > 0)) && (is_on_floor() || (coyoteTimer > 0))):
			velocity.y = -jumpSpeed;
			coyoteTimer = 0;
	velocity.x = clamp(velocity.x, -maxSpeedX, maxSpeedX);
	velocity.y = clamp(velocity.y, -maxSpeedY, maxSpeedY);
	if velocity.y > 0:
		$FeetShape.disabled = false;
	else:
		$FeetShape.disabled = true;
	velocity = move_and_slide(velocity, Vector2(0,-1));

func advanceCooldowns(delta: float) -> void:
	if is_on_floor():
		coyoteTimer = coyoteTime;
	else:
		coyoteTimer -= delta;
	if actionCooldown > 0:
		actionCooldown -= delta;
	jumpBufferTimer -= delta;


func actionHold() -> void:
	if holdAction == HoldAction.block:
		block();
	else:
		bolt();
	
func actionInst() -> void:
	if instantAction == InstantAction.punch:
		punch();
	else:
		blast();
	
func punch() -> void:
	if (actionCooldown > 0):
		return
	$CharacterSprite.set_frame(0)
	$CharacterSprite.play("Punch");
	$PunchPlayer.play()
	actionCooldown = 0.5;
	# yield($CharacterSprite, "animation_finished")
	

func blast() -> void:
	if (actionCooldown > 0):
		return
	pass
	$CharacterSprite.set_frame(4)
	$CharacterSprite.play("Punch");
	$BlastPlayer.play()
	actionCooldown = 0.3;
	# yield($CharacterSprite, "animation_finished")
	
	
func block() -> void:
	if (actionCooldown > 0):
		return
	actionCooldown = 1000;
	$ShieldPlayer.play()
	$CharacterSprite/Shield.visible = true;
	if $CharacterSprite.flip_h:
		$CharacterSprite/Shield.flip_h = true;
		$CharacterSprite/Shield.offset.x = -8;
	else:
		$CharacterSprite/Shield.flip_h = false;
		$CharacterSprite/Shield.offset.x = 8;
	shieldActive = true;
	
func bolt() -> void:
	if (actionCooldown > 0):
		return
	$CharacterSprite.speed_scale = 0.5;
	$CharacterSprite.play("Punch", true);	# reversed punch animation
	$CharacterSprite.frame = 12;
	$ChargePlayer.play();
	actionCooldown = 1;
	yield($ChargePlayer, "finished");
	$BoltPlayer.play();
	# launch bolt

func actionHoldRelease() -> void:
	actionCooldown = 0;
	$ChargePlayer.stop();
	$CharacterSprite/Shield.visible = false;
	shieldActive = false;
	

func _on_Randomize_timeout() -> void:
	randomizeActions();
	$RandomizeTimer.wait_time = rand_range(5, 8);
	$RandomizeTimer.start();
