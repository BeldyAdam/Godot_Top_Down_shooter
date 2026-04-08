extends Control

func _on_jatek_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")

func _on_kilepes_pressed() -> void:
	get_tree().quit()
