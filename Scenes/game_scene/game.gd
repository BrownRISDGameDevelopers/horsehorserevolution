extends Node2D

var score = 0
var combo = 0

var max_combo = 0
var great = 0
var good = 0
var okay = 0
var missed = 0

@onready var controls = $Controls

@onready var enemy_bar_node: Node2D = $EnemyBar
@onready var enemy_bar: TextureProgressBar = enemy_bar_node.get_node("ProgressBar")

@onready var enemy_horse: Node2D = $EnemyHorse
@onready var player_horse: Node2D = $PlayerHorse

var sync_health: int = 6
var player1hit: int = 0
var player2hit: int = 0
 
signal level_won
signal level_lost

func _ready():
	Global.beat.connect(enemy_strike_pose)
	Global.beat.connect(handle_sync_health)
	Global.level_over.connect(complete_level)
	Global.note_hit.connect(handle_note_hit)
	$AnimationPlayer.play("start_with_animations")

func handle_note_hit(player: Global.PlayerEnum, area: Global.AreaHit, note_score: Global.ScoreEnum):
	if player == Global.PlayerEnum.PLAYER_1:
		player1hit += area
	else:
		player2hit += area
	increment_score(note_score)

func handle_sync_health(_beat_position):
	if controls.sync_phase:
		if abs(player1hit - player2hit) > 3:
			sync_health -= 1
			$RaceLights.remove_health()
			if sync_health <= 0:
				lose_with_animations()
			else:
				slip_players(false)
	player1hit = 0
	player2hit = 0

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
	
	if enemy_bar.value >= 200:
		lose_with_animations()
	score += note_score * combo

	$ComboDisplay.set_combo(combo)
	if combo > max_combo:
		max_combo = combo
	
func enemy_strike_pose(_beat_position):
	enemy_horse.strike_pose(enemy_bar.value)

func start_level():
	controls.play_from_beat(1)

func lose_with_animations():
	slip_players(true)
	$Controls/Conductor.stop()
	$AnimationPlayer.play("lose_fadeout")

func slip_players(permanent = false):
	player_horse.slip(permanent)
	if has_node("PlayerHorseMirror"):
		$PlayerHorseMirror.slip(permanent)

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

func _on_controls_refresh_health():
	$RaceLights.add_health()
	$RaceLights.add_health()
