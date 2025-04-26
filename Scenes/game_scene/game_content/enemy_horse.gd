extends Node2D

@export var great: Sprite2D
@export var mildly_good: Sprite2D
@export var mildly_bad: Sprite2D
@export var bad: Sprite2D
@export var static_pose: Sprite2D
@export var pose_length: float
@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.wait_time = pose_length

func strike_pose(dancebarval): # between 0 and 200
	if (timer.is_stopped()):
		var rand = randi_range(0, 200)
		if (rand * 4 < dancebarval):
			set_pose(bad)
		elif (rand < dancebarval):
			set_pose(mildly_bad)
		elif (rand / 2.0 >= dancebarval):
			set_pose(great)
		else:
			set_pose(mildly_good)
		timer.start()
	return

func set_pose(pose_node: Sprite2D):
	great.visible = false
	mildly_good.visible = false
	mildly_bad.visible = false
	bad.visible = false
	static_pose.visible = false
	
	pose_node.visible = true

func _on_timer_timeout() -> void:
	set_pose(static_pose)
