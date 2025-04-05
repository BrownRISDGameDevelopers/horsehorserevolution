extends Sprite2D

@export var great: Texture2D
@export var mildlygood: Texture2D
@export var mildlybad: Texture2D
@export var bad: Texture2D
@export var static_pose: Texture2D

func strike_pose(dancebarval): # between 0 and 200
	var rand = randi_range(0,200)
	if (rand * 4 < dancebarval):
		texture = bad
	elif (rand < dancebarval):
		texture = mildlybad
	elif (rand / 2 >= dancebarval):
		texture = great
	else:
		texture = mildlygood
	
	return
