extends Control

var song: Song
var base_level: String

func instantiate(_song, _base_level):
	song = _song
	add_child(song)
	base_level = _base_level
	$CustomLevelManager.instantiate(song, base_level)