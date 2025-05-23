extends Node2D

enum MergeType {DISCO, COUNTRY, DEATHMETAL, TUTORIAL}
enum PlayerEnum {PLAYER_1, PLAYER_2}
enum ScoreEnum {MISS, OKAY, GOOD, PERFECT}
enum Direction {LEFT, DOWN, UP, RIGHT}
enum AreaHit {OKAY_UPPER, GOOD_UPPER, PERFECT, GOOD_LOWER, OKAY_LOWER, MISS = 7}

signal beat(position)
signal level_over
signal dance_bar_change(x)
signal note_hit(player, area, score, beat)

signal restart_custom_level