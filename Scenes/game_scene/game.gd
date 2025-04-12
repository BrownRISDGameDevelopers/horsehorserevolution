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
	Global.beat.connect(enemy_strike_pose)
	Global.level_over.connect(complete_level)
	Global.note_hit.connect(handle_note_hit)

func handle_note_hit(player: Global.PlayerEnum, area: Global.AreaHit, note_score: Global.ScoreEnum):
	if player == Global.PlayerEnum.PLAYER_1:
		player1hit = area
	else:
		player2hit = area
	handle_sync_health()
	increment_score(note_score)

func handle_sync_health():
	if controls.sync_phase and abs(player1hit - player2hit) > 2:
		sync_health -= 1
		print(sync_health)

func increment_score(note_score: Global.ScoreEnum):
	if note_score != Global.ScoreEnum.MISS:
		combo += 1
	else:
		combo = 0
	
	if note_score == Global.ScoreEnum.PERFECT:
		great += 1
		dance_bar1.value += 15
		dance_bar2.value -= 15
	elif note_score == Global.ScoreEnum.GOOD:
		good += 1
		dance_bar1.value += 10
		dance_bar2.value -= 10
	elif note_score == Global.ScoreEnum.OKAY:
		okay += 1
		dance_bar1.value += 5
		dance_bar2.value -= 5
	else:
		missed += 1
		dance_bar1.value -= 5
		dance_bar2.value += 5
	
	if dance_bar1.value <= 0 or dance_bar2.value >= 200:
		game_over()
	score += note_score * combo

	$Combo.text = "x" + str(combo)
	if combo > max_combo:
		max_combo = combo

func game_over():
	level_lost.emit()

func complete_level():
	level_won.emit()
	
func enemy_strike_pose():
	enemy_horse.strike_pose(dance_bar1.value)
