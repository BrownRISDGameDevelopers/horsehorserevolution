extends Sprite2D

@export var roadNum : int
var distanceFromCenter = 80
@onready var tween = get_tree().create_tween()

func _ready():
	if (roadNum == 2):
		distanceFromCenter *= -1
	enter_sync()
	exit_sync()

func enter_sync():
	tween.tween_property(self, "position", Vector2(position.x + distanceFromCenter, position.y), 2)
	
func exit_sync():
	tween.tween_property(self, "position", Vector2(position.x, position.y), 2)
