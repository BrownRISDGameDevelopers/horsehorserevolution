extends Node2D

var combo = 0

@onready var controls = $Controls

@onready var enemy_bar_node: Node2D = $EnemyBar
@onready var enemy_bar: TextureProgressBar = enemy_bar_node.get_node("ProgressBar")

@onready var player_horse: Node2D = $PlayerHorse

@export var start_beat_for_testing := 1

var sync_health: int = 3
 
signal level_won
signal level_lost

func _ready():
	Global.level_over.connect(complete_level)
	Global.note_hit.connect(increment_score)
	controls.sync_slip.connect(lose_sync_health)
	$AnimationPlayer.play("start_with_animations")


func increment_score(_player: Global.PlayerEnum, _area: Global.AreaHit, note_score: Global.ScoreEnum, _beat):
	if note_score != Global.ScoreEnum.MISS:
		combo += 1
	else:
		combo = 0
	
	if note_score == Global.ScoreEnum.PERFECT:
		Global.dance_bar_change.emit(15)
	elif note_score == Global.ScoreEnum.GOOD:
		Global.dance_bar_change.emit(10)
	elif note_score == Global.ScoreEnum.OKAY:
		Global.dance_bar_change.emit(5)
	else:
		Global.dance_bar_change.emit(-10)
	
	if enemy_bar.value >= 200:
		lose_with_animations()

	$ComboDisplay.set_combo(combo)

func lose_sync_health():
	sync_health -= 1
	slip_players()
	$RaceLights.remove_health()
	if sync_health == 0:
		lose_with_animations()
	
func start_level():
	controls.play_from_beat(start_beat_for_testing)

func lose_with_animations():
	slip_players(true)
	$Controls/Conductor.stop()
	$AnimationPlayer.play("lose_fadeout")

func slip_players(permanent = false):
	player_horse.slip(permanent)
	if has_node("PlayerHorseMirror"):
		$PlayerHorseMirror.slip(permanent)

func _on_controls_refresh_health():
	$RaceLights.add_health()
	$RaceLights.add_health()
	$RaceLights.add_health()

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