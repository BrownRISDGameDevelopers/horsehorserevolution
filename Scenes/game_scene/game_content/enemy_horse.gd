extends Node2D

@export var great: Sprite2D
@export var mildly_good: Sprite2D
@export var mildly_bad: Sprite2D
@export var bad: Sprite2D
@export var static_pose: Sprite2D
@export var pose_length: float

@export var great_chance: int = 10
@export var good_chance: int = 50
@export var poor_chance: int = 30
@export var bad_chance: int = 10

@onready var timer: Timer = $Timer

func _ready() -> void:
	Global.beat.connect(strike_pose)
	timer.wait_time = pose_length

func strike_pose(_beat_position):
	if timer.is_stopped():
		var rand = randi_range(0, bad_chance + poor_chance + good_chance + great_chance)
		if rand < bad_chance:
			set_pose(bad)
		elif rand < bad_chance + poor_chance:
			set_pose(mildly_bad)
		elif rand < bad_chance + poor_chance + good_chance:
			set_pose(great)
		else:
			set_pose(mildly_good)
		timer.start()

func set_pose(pose_node: Sprite2D):
	great.visible = false
	mildly_good.visible = false
	mildly_bad.visible = false
	bad.visible = false
	static_pose.visible = false
	
	pose_node.visible = true

func _on_timer_timeout() -> void:
	set_pose(static_pose)
