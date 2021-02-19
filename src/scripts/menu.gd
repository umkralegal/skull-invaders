extends Control
# Main menu.


func _on_ButtonPlay_pressed():
	SceneManager.goto_scene("res://src/scenes/game.tscn")


func _on_ButtonCreditsLicense_pressed():
	if $PanelCreditsLicense.visible:
		$PanelCreditsLicense.hide()
		return
	else:
		$PanelCreditsLicense.show()


func _on_ButtonExit_pressed():
	get_tree().quit()
