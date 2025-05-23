extends Node

## Required path to a main menu scene.
@export_file("*.tscn") var main_menu_scene: String
## Optional path to an ending scene.
@export_file("*.tscn") var ending_scene: String
## Optional reference to a loading screen in the scene.
@export var level_loading_screen: LoadingScreen
## Optional win screen to be shown after the last level is won.
@export var game_won_scene: PackedScene
## Optional lose screen to be shown after the level is lost.
@export var level_lost_scene: PackedScene

## Container where the level instance will be added.
@export var level_container: Node
@export var song: Song

@export_file("*.tscn") var base_level: String
var current_level

func _try_connecting_signal_to_node(node: Node, signal_name: String, callable: Callable):
	if node.has_signal(signal_name) and not node.is_connected(signal_name, callable):
		node.connect(signal_name, callable)

func _try_connecting_signal_to_level(signal_name: String, callable: Callable):
	_try_connecting_signal_to_node(current_level, signal_name, callable)
	
func _connect_level_signals():
	_try_connecting_signal_to_level(&"level_won", _on_level_won)
	_try_connecting_signal_to_level(&"level_lost", _on_level_lost)

func _on_level_won():
	_load_win_screen_or_ending()

func _reload_level():
	load_current_level()

func _attach_level(level_resource: Resource):
	assert(level_container != null, "level_container is null")
	var instance = level_resource.instantiate()
	level_container.call_deferred("add_child", instance)
	return instance

func load_current_level():
	if level_loading_screen:
		level_loading_screen.reset()
	if is_instance_valid(current_level):
		current_level.queue_free()
		await current_level.tree_exited
		current_level = null
	SceneLoader.load_scene(base_level, true)
	await SceneLoader.scene_loaded
	current_level = _attach_level(SceneLoader.get_resource())
	current_level.song = song
	await current_level.ready
	_connect_level_signals()
	if level_loading_screen:
		level_loading_screen.close()

func _load_win_screen_or_ending():
	if game_won_scene:
		var instance = game_won_scene.instantiate()
		get_tree().current_scene.add_child(instance)
		_try_connecting_signal_to_node(instance, &"continue_pressed", _load_ending)
		_try_connecting_signal_to_node(instance, &"restart_pressed", _reload_level)
		_try_connecting_signal_to_node(instance, &"main_menu_pressed", _load_main_menu)
	else:
		_load_ending()
		
func _on_level_lost():
	if level_lost_scene:
		var instance = level_lost_scene.instantiate()
		get_tree().current_scene.add_child(instance)
		_try_connecting_signal_to_node(instance, &"restart_pressed", _reload_level)
		_try_connecting_signal_to_node(instance, &"main_menu_pressed", _load_main_menu)
	else:
		_reload_level()

func _load_main_menu():
	SceneLoader.load_scene(main_menu_scene)

func _load_ending():
	if ending_scene:
		SceneLoader.load_scene(ending_scene)
	else:
		_load_main_menu()

func _ready():
	load_current_level()
