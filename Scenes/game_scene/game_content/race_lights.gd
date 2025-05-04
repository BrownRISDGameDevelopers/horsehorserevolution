extends Node2D

@export var light_array: Array[Sprite2D]
@export var red_light: Texture2D
@export var green_light: Texture2D
var health = 0

func _ready():
	for light in light_array:
		light.texture = red_light

func add_health():
	if health == 3:
		return
	light_array[health].texture = green_light
	health += 1
	

func remove_health():
	health -= 1
	light_array[health].texture = red_light
