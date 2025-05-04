extends Node2D

@export var light_array: Array[Sprite2D]
@export var red_light: Texture2D
@export var green_light: Texture2D
var health = 0
var buffer = 1

func _ready():
	for light in light_array:
		light.texture = red_light

func add_health():
	if health == 3:
		return
	light_array[health].texture = green_light
	health += 1
	buffer = 1
	

func remove_health():
	buffer -= 1
	if buffer == 0:
		buffer = 1
		health -= 1
		light_array[health].texture = red_light
