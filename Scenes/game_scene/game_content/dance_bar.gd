extends Node2D

@onready var bar_1: TextureProgressBar = $TextureProgressBar1
@onready var bar_2: TextureProgressBar = $TextureProgressBar2

func _ready():
	Global.dance_bar_change.connect(change_val)
	
func change_val(x):
	bar_1.value += x
	bar_2.value -= x
