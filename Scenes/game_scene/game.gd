extends Node2D

var score = 0
var combo = 0

var max_combo = 0
var great = 0
var good = 0
var okay = 0
var missed = 0

@onready var controls = $Controls

@onready var dance_bar_node: Node2D = $DanceBar
@onready var dance_bar1: TextureProgressBar = dance_bar_node.get_node("TextureProgressBar1")
@onready var dance_bar2: TextureProgressBar = dance_bar_node.get_node("TextureProgressBar2")

@onready var enemy_horse: Sprite2D = $EnemyHorse

var sync_health: int = 3
var player1hit: int = -1
var player2hit: int = -1
 
signal level_won
signal level_lost

func _ready():
	controls.play_from_beat(1)
	Global.enemy_strike_pose.connect(enemy_strike_pose)
	Global.level_over.connect(complete_level)

# TODO: everything below with signals
func set_player1hit(areaNum):
	player1hit = areaNum
	#print(player2hit)
	if player2hit != 0:
		# if sync_phase:
		if abs(player1hit - player2hit) > 2:
			sync_health -= 1
			print(sync_health)
		player1hit = 0
		player2hit = 0

func set_player2hit(areaNum):
	player2hit = areaNum
	#print(player1hit)
	if player1hit != 0:
		if abs(player1hit - player2hit) > 2:
			sync_health -= 1
			print(sync_health)
		player1hit = 0
		player2hit = 0

func increment_score(by):
	if by > 0:
		combo += 1
	else:
		combo = 0
	
	if by == 3:
		great += 1
		dance_bar1.value += 15
		dance_bar2.value -= 15
	elif by == 2:
		good += 1
		dance_bar1.value += 10
		dance_bar2.value -= 10
	elif by == 1:
		okay += 1
		dance_bar1.value += 5
		dance_bar2.value -= 5
	else:
		missed += 1
		dance_bar1.value -= 5
		dance_bar2.value += 5
	
	# if dance_bar1.value == 0 or dance_bar2.value == 200:
	# 	game_over()
	score += by * combo
	$Label.text = str(score)
	if combo > 0:
		$Combo.text = str(combo) + " combo!"
		if combo > max_combo:
			max_combo = combo
	else:
		$Combo.text = ""

func game_over():
	level_lost.emit()

func complete_level():
	level_won.emit()

func reset_combo():
	combo = 0
	$Combo.text = ""
	
func enemy_strike_pose():
	enemy_horse.strike_pose(dance_bar1.value)
