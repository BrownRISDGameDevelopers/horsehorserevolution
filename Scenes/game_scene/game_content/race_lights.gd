extends Node2D

@export var light_array: Array[Sprite2D]
const RED = "red"
const GREEN = "green"
var light_colors = {RED: "EE4655", GREEN: "45AF40"}
var health = 0

func _ready():
    for light in light_array:
        light.modulate = light_colors[RED]

func add_health():
    if health == 3:
        return
    light_array[health].modulate = light_colors[GREEN]
    health += 1
    

func remove_health():
    health -= 1
    light_array[health].modulate = light_colors[RED]
