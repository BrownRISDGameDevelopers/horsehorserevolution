extends Node2D

@export var is_player: bool = false
@onready var bar: TextureProgressBar = $ProgressBar

const RED = "red"
const GREEN = "green"
var bar_colors = {RED: "ED272F", GREEN: "3BB45A"}

func _ready():
	if is_player:
		bar.modulate = bar_colors[GREEN]
	else:
		bar.modulate = bar_colors[RED]
		bar.fill_mode = 1
	Global.dance_bar_change.connect(change_val)
	
func change_val(x):
	if is_player:
		bar.value = min(200, max(bar.value + x, 10))
	else:
		bar.value = min(200, max(bar.value - x, 10))
