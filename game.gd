extends Node2D

var score := 0
@onready var score_label = %ScoreLabel

func _ready():
	score_label.text = "Score: 0"

var enemy_scenes = [
	preload("res://mob.tscn"),
	preload("res://mob_2.tscn")
]

func spawn_mob():
	var enemy_scene = enemy_scenes.pick_random()
	var new_mob = enemy_scene.instantiate()

	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)

func _on_timer_timeout():
	spawn_mob()

func _on_player_health_depleted():
	%GameOver.visible = true
	get_tree().paused = true
	
	score = 0
	%ScoreLabel.text = "Score: 0"
	
func add_score(amount):
	score += amount
	score_label.text = "Score: " + str(score)

func _on_back_to_main_menu_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
