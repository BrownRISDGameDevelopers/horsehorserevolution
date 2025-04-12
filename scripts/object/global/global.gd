extends Node2D


var score = 0
var combo = 0
var great = 0
var good = 0
var okay = 0
var missed = 0
var grade = "NA"

enum PlayerEnum {PLAYER_1, PLAYER_2}
enum ScoreEnum {MISS, OKAY, GOOD, PERFECT}
enum Direction {LEFT, DOWN, UP, RIGHT}
enum AreaHit {OKAY_UPPER, GOOD_UPPER, PERFECT, GOOD_LOWER, OKAY_LOWER, MISS = 7}

signal beat
signal level_over
signal dance_bar_change(x)
signal note_hit(player, area, score)

func set_score(new):
	score = new
	if score > 250000:
		grade = "A+"
	elif score > 200000:
		grade = "A"
	elif score > 150000:
		grade = "A-"
	elif score > 130000:
		grade = "B+"
	elif score > 115000:
		grade = "B"
	elif score > 100000:
		grade = "B-"
	elif score > 85000:
		grade = "C+"
	elif score > 70000:
		grade = "C"
	elif score > 55000:
		grade = "C-"
	elif score > 40000:
		grade = "D+"
	elif score > 30000:
		grade = "D"
	elif score > 20000:
		grade = "D-"
	else:
		grade = "F"
