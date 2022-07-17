extends Label

export var player = 1;

func _ready() -> void:
	var thisColour: Color = Color("#FFAA5E") if (player == 1) else Color("#5FFF62");
	add_color_override("font_color", thisColour);

func updateHealth(value: float):
	text = String(value);
