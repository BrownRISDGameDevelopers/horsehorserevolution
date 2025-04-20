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

@onready var enemy_horse: Node2D = $EnemyHorse
@onready var player_horse: Node2D = $PlayerHorse

var sync_health: int = 3
var player1hit: int = -1
var player2hit: int = -1
 
signal level_won
signal level_lost

func _ready():
	Global.beat.connect(enemy_strike_pose)
	Global.level_over.connect(complete_level)
	Global.note_hit.connect(handle_note_hit)
	$AnimationPlayer.play("start_with_animations")

func handle_note_hit(player: Global.PlayerEnum, area: Global.AreaHit, note_score: Global.ScoreEnum):
	if player == Global.PlayerEnum.PLAYER_1:
		player1hit = area
	else:
		player2hit = area
	handle_sync_health()
	increment_score(note_score)

func handle_sync_health():
	if controls.sync_phase:
		# Only lose 1 sync health per beat
		if abs(player1hit - player2hit) > 2 and player1hit != Global.AreaHit.MISS or player2hit != Global.AreaHit.MISS:
			sync_health -= 1
			player1hit = Global.AreaHit.MISS
			player2hit = Global.AreaHit.MISS
			$RaceLights.remove_health()
			if sync_health == 0:
				lose_with_animations()
			else:
				player_horse.slip()

func increment_score(note_score: Global.ScoreEnum):
	if note_score != Global.ScoreEnum.MISS:
		combo += 1
	else:
		combo = 0
	
	if note_score == Global.ScoreEnum.PERFECT:
		great += 1
		Global.dance_bar_change.emit(15)
	elif note_score == Global.ScoreEnum.GOOD:
		good += 1
		Global.dance_bar_change.emit(10)
	elif note_score == Global.ScoreEnum.OKAY:
		okay += 1
		Global.dance_bar_change.emit(5)
	else:
		missed += 1
		Global.dance_bar_change.emit(-10)
	
	if dance_bar1.value <= 0 or dance_bar2.value >= 200:
		lose_with_animations()
	score += note_score * combo

	$ComboDisplay.set_combo(combo)
	if combo > max_combo:
		max_combo = combo
	
func enemy_strike_pose(_beat_position):
	enemy_horse.strike_pose(dance_bar1.value)

func start_level():
	controls.play_from_beat(1)

func lose_with_animations():
	player_horse.slip(true)
	$Controls/Conductor.stop()
	$AnimationPlayer.play("lose_fadeout")

func pause_before_lose() -> void:
	var process_setters = ["set_process",
	"set_physics_process",
	"set_process_input",
	"set_process_unhandled_input",
	"set_process_unhandled_key_input",
	"set_process_shortcut_input", ]
	
	for setter in process_setters:
		self.propagate_call(setter, [false])

func game_over():
	level_lost.emit()

func complete_level():
	level_won.emit()
