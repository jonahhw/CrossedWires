extends KinematicBody2D

var health: float = 100;

var moveBuffer: Vector2 = Vector2(0, 0);
var velocity: Vector2 = Vector2(0,0);

export var accelerationX: float = 1000;
export var maxSpeedX: float = 150;
export var friction: float = 600;

var facingRight: bool = true;

export var jumpSpeed = 300;
export var coyoteTime = 0.05;				# extra time for jumps to be allowed if not touching ground
var coyoteTimer = 0;						# keeps track of time since fallen off a ledge
export var jumpBufferTime = 0.1;					# jump buffering
var jumpBufferTimer = 0;							# keeps track of time since pressing the jump button for jump buffering
export var gravitySpeed = 2000;
export var maxSpeedY = 1000;
func gravSpeedCoeff() -> float:
	if isJumpPressed():
		return 0.4;
	else:
		return 1.0;

# TODO: make a horizontal flip variable/function that automatically moves the shield, & punch and flips everything that needs to be flipped

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

const BlastScene = preload("res://src/Blast.tscn");
const BoltScene = preload("res://src/Bolt.tscn");

signal blast_launched;
signal bolt_started;
signal damaged(health_remaining);

# input functions - to be overridden
func isJumpPressed() -> bool:
	return false;
func horizontalAxis() -> float:
	return 0.0;

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
				faceLeft();
			else:
				faceRight();
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

func faceLeft() -> void:
	facingRight = false;
	$CharacterSprite.flip_h = true;
	$CharacterSprite.offset.x = -8;
	$PunchArea/PunchShape.transform = Transform2D(0, Vector2(-5, -13));
	$CharacterSprite/Shield.flip_h = true;
	$CharacterSprite/Shield.offset.x = -15;
	$ShieldArea/ShieldShape.transform = Transform2D(0, Vector2(-3, -12));
	
func faceRight() -> void:
	facingRight = true;
	$CharacterSprite.flip_h = false;
	$CharacterSprite.offset.x = 0;
	$PunchArea/PunchShape.transform = Transform2D(0, Vector2(20, -13));
	$CharacterSprite/Shield.flip_h = false;
	$CharacterSprite/Shield.offset.x = 8;
	$ShieldArea/ShieldShape.transform = Transform2D(0, Vector2(20, -12));

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
	$PunchArea/PunchShape.disabled = false;
	$PunchPlayer.play()
	actionCooldown = 0.3;
	yield(get_tree().create_timer(0.1), "timeout");
	$PunchArea/PunchShape.disabled = true;

func blast() -> void:
	if (actionCooldown > 0):
		return
	pass
	$CharacterSprite.set_frame(4)
	$CharacterSprite.play("Punch");
	$BlastPlayer.play()
	actionCooldown = 0.2;
	var thisBlast = BlastScene.instance();
	thisBlast.direction = $CharacterSprite.flip_h;
	thisBlast.position = $PunchArea/PunchShape.position;
	add_child(thisBlast);
	
	
func block() -> void:
	if (actionCooldown > 0):
		return
	actionCooldown = 1000;
	$ShieldPlayer.play()
	$CharacterSprite/Shield.visible = true;
	$ShieldArea/ShieldShape.disabled = false;
	shieldActive = true;
	
func bolt() -> void:
	if (actionCooldown > 0):
		return
	$CharacterSprite.speed_scale = 0.5;
	$CharacterSprite.play("Punch", true);	# reversed punch animation
	$CharacterSprite.frame = 11;
	$ChargePlayer.play();
	actionCooldown = 1;
	yield($ChargePlayer, "finished");
	$BoltPlayer.play();
	var thisBolt = BoltScene.instance();
	thisBolt.position = Vector2(165,-12) if facingRight else Vector2(-144,-12);
	add_child(thisBolt);

func actionHoldRelease() -> void:
	actionCooldown = 0;
	$ChargePlayer.stop();
	$CharacterSprite/Shield.visible = false;
	$ShieldArea/ShieldShape.disabled = true;
	shieldActive = false;
	

func _on_Randomize_timeout() -> void:
	randomizeActions();
	$RandomizeTimer.wait_time = rand_range(5, 8);
	$RandomizeTimer.start();


func _on_HurtArea_area_entered(area: Area2D) -> void:
	var collidingBody = area.name;	# My apologies to the programming gods for using string comparisons.
	# In my defense, we have 4 hours to submit and I've hardly started on the music.
	# TODO remove name-based detection and properly check if the collision area belongs to another mech
	if collidingBody == "Blast":
		damage(0 if shieldActive else 5);
	elif collidingBody == "Bolt":
		damage(13 if shieldActive else 42)	# TODO check if facing the right direction?
	elif collidingBody == "PunchArea":
		damage(2 if shieldActive else 8)	# TODO check if facing the right direction
	
func damage(amount: float):
	health -= amount;
	emit_signal("damaged", health)



func _on_ShieldArea_area_entered(area: Area2D) -> void:
	var collidingBody = area.name;
	if collidingBody == "Blast":
		$DingPlayer.play();
	elif collidingBody == "Bolt":
		pass
	elif collidingBody == "PunchArea":
		$DingPlayer.play();
