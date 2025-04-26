extends Node2D

class DoubleLinkedList:
	var prev_node: DoubleLinkedList = null
	var next_node: DoubleLinkedList = null
	var base_node: bool = false
	var state: Global.Direction

	func _init(_state: Global.Direction, _prev_node: DoubleLinkedList = null):
		if _prev_node != null:
			prev_node = _prev_node
			_prev_node.next_node = self
			state = _state
		else:
			base_node = true

	func _pop():
		prev_node.next_node = next_node
		if next_node != null:
			next_node.prev_node = prev_node

	func last_node() -> DoubleLinkedList:
		if next_node == null:
			return self
		else:
			return next_node.last_node()

	func find_state(_state: Global.Direction):
		if not base_node and state == _state:
			return self
		elif next_node != null:
			return next_node.find_state(_state)
		else:
			return null

	func pop_state(_state: Global.Direction):
		var node_with_state = find_state(_state)
		if node_with_state != null:
			node_with_state._pop()

	func add_state(_state: Global.Direction):
		var node_with_state = find_state(_state)
		if node_with_state == null:
			var _new_node = DoubleLinkedList.new(_state, self.last_node())

var current_states: Array[DoubleLinkedList] = [DoubleLinkedList.new(Global.Direction.LEFT), DoubleLinkedList.new(Global.Direction.LEFT)]

@export var back_sprites: Array[Sprite2D]
@export var front_sprites: Array[Sprite2D]
@export var reset_timers: Array[Timer]

@export var pose_duration = 0.16

func _physics_process(delta):
	for player in Global.PlayerEnum:
		for direction in Global.Direction:
			var input_name = direction.to_lower() + str(Global.PlayerEnum[player])
			if Input.is_action_just_pressed(input_name):
				current_states[Global.PlayerEnum[player]].add_state(Global.Direction[direction])
				reset_timers[Global.PlayerEnum[player]].stop()
			if Input.is_action_just_released(input_name):
				current_states[Global.PlayerEnum[player]].pop_state(Global.Direction[direction])
		set_visibility(Global.PlayerEnum[player])

func set_visibility(player: Global.PlayerEnum):
	var sprite_list
	var player_node = current_states[player].last_node()
	if player == Global.PlayerEnum.PLAYER_1:
		sprite_list = back_sprites
	else:
		sprite_list = front_sprites
	if player_node.base_node:
		if reset_timers[player].is_stopped():
			reset_timers[player].start(pose_duration)
	else:
		for sprite in sprite_list:
			sprite.visible = false
		sprite_list[player_node.state].visible = true

func reset_pose(sprite_list):
	for sprite in sprite_list:
		sprite.visible = false
	sprite_list[-1].visible = true

func set_slip_visibility(is_slipped):
	$PlayerBack.visible = !is_slipped
	$PlayerFront.visible = !is_slipped
	$PlayerConnector.visible = !is_slipped
	$PlayerTape.visible = !is_slipped
	$PlayerSlip.visible = is_slipped

func slip(permanent = false):
	set_slip_visibility(true)
	if not permanent:
		$SlipTimer.start(pose_duration)
	else:
		$SlipTimer.stop()

func _on_back_timer_timeout():
	reset_pose(back_sprites)

func _on_front_timer_timeout():
	reset_pose(front_sprites)

func _on_slip_timer_timeout():
	set_slip_visibility(false)
