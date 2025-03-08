extends Area2D

const TARGET_Y = 164
const SPAWN_Y = -16
const DIST_TO_TARGET = TARGET_Y - SPAWN_Y

const LEFT_LANE_SPAWN_1 = Vector2(20, SPAWN_Y)
const DOWN_LANE_SPAWN_1 = Vector2(60, SPAWN_Y)
const UP_LANE_SPAWN_1 = Vector2(100, SPAWN_Y)
const RIGHT_LANE_SPAWN_1 = Vector2(140, SPAWN_Y)

const LEFT_LANE_SPAWN_2 = Vector2(180, SPAWN_Y)
const DOWN_LANE_SPAWN_2 = Vector2(220, SPAWN_Y)
const UP_LANE_SPAWN_2 = Vector2(260, SPAWN_Y)
const RIGHT_LANE_SPAWN_2 = Vector2(300, SPAWN_Y)

var speed = 0
var hit = false

var dance_bar: TextureProgressBar

func _ready():
	pass


func _physics_process(delta):
	if !hit:
		position.y += speed * delta
		if position.y > 200:
			dance_bar.value -= 10
			queue_free()
			get_parent().reset_combo()
	else:
		$Node2D.position.y -= speed * delta


func initialize(lane):
	if lane == 0:
		$AnimatedSprite2D.frame = 0
		position = LEFT_LANE_SPAWN_1
	elif lane == 1:
		$AnimatedSprite2D.frame = 1
		$AnimatedSprite2D.rotation = PI
		position = DOWN_LANE_SPAWN_1
	elif lane == 2:
		$AnimatedSprite2D.frame = 1
		position = UP_LANE_SPAWN_1
	elif lane == 3:
		$AnimatedSprite2D.frame = 2
		position = RIGHT_LANE_SPAWN_1
	elif lane == 4:
		$AnimatedSprite2D.frame = 0
		position = LEFT_LANE_SPAWN_2
	elif lane == 5:
		$AnimatedSprite2D.frame = 1
		$AnimatedSprite2D.rotation = PI
		position = DOWN_LANE_SPAWN_2
	elif lane == 6:
		$AnimatedSprite2D.frame = 1
		position = UP_LANE_SPAWN_2
	elif lane == 7:
		$AnimatedSprite2D.frame = 2
		position = RIGHT_LANE_SPAWN_2
	else:
		printerr("Invalid lane set for note: " + str(lane))
		return
	
	speed = DIST_TO_TARGET / 2.0


func destroy(score):
	$CPUParticles2D.emitting = true
	$AnimatedSprite2D.visible = false
	$Timer.start()
	hit = true
	if score == 3:
		$Node2D/Label.text = "GREAT"
		$Node2D/Label.modulate = Color("f6d6bd")
	elif score == 2:
		$Node2D/Label.text = "GOOD"
		$Node2D/Label.modulate = Color("c3a38a")
	elif score == 1:
		$Node2D/Label.text = "OKAY"
		$Node2D/Label.modulate = Color("997577")


func _on_Timer_timeout():
	queue_free()
