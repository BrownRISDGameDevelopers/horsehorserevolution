extends Node2D

@export var combo_text: Label

func _ready():
    Global.beat.connect(pulse)

func pulse(_beat):
    $AnimationPlayer.play("pulse")

func set_combo(combo: int):
    combo_text.text = "x" + str(combo)
