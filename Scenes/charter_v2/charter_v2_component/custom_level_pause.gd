extends PauseMenu

func _on_confirm_restart_confirmed():
	Global.restart_custom_level.emit()
	close()