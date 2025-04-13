extends Sprite2D

@export var great: Texture2D
@export var mildlygood: Texture2D
@export var mildlybad: Texture2D
@export var bad: Texture2D
@export var static_pose: Texture2D
@onready var timer: Timer = $Timer

func strike_pose(dancebarval): # between 0 and 200
	if (timer.is_stopped()):
		var rand = randi_range(0, 200)
		if (rand * 4 < dancebarval):
			texture = bad
		elif (rand < dancebarval):
			texture = mildlybad
		elif (rand / 2.0 >= dancebarval):
			texture = great
		else:
			texture = mildlygood
		timer.start()
	return


func _on_timer_timeout() -> void:
	texture = static_pose
