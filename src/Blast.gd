extends Area2D

export var speed: float = 300;
enum Direction {
	Right,
	Left
}
var direction: int;

func _ready() -> void:
	if direction == Direction.Left:
		flipDirection();

func flipDirection() -> void:
	$Sprite.flip_h = !$Sprite.flip_h;
	speed *= -1;

func _physics_process(delta: float) -> void:
	transform = transform.translated(Vector2(speed*delta, 0));

func destroy(reason: String = "") -> void:
	queue_free()


func _on_Blast_body_entered(body: Node) -> void:
	# maybe some impact sound effect
	destroy()


func _on_Blast_area_entered(area: Area2D) -> void:
	if area.name == "ShieldArea":
		direction = !direction;
		flipDirection()
	elif area.name == "PunchArea":
		return
	else:
		destroy()
