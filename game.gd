extends Node2D

var score := 0
@onready var score_label = %ScoreLabel
@onready var spawn_timer = %Timer
@onready var wave_label = %WaveLabel

var current_wave := 0
var enemies_spawned_in_wave := 0
var alive_enemies := 0
var wave_in_progress := false
var active_enemy_count := 0
var active_spawn_interval := 1.0

var mob_types = {
	"slime": preload("res://mob.tscn"),
	"skeleton": preload("res://mob_2.tscn")
}

var waves = [
	{
		"name": "1",
		"enemy_count": 3,
		"spawn_interval": 2.0,
		"allowed_mobs": ["slime"]
	},
	{
		"name": "2",
		"enemy_count": 5,
		"spawn_interval": 1.7,
		"allowed_mobs": ["slime"]
	},
	{
		"name": "3",
		"enemy_count": 6,
		"spawn_interval": 1.5,
		"allowed_mobs": ["slime", "skeleton"]
	},
	{
		"name": "4",
		"enemy_count": 8,
		"spawn_interval": 1.2,
		"allowed_mobs": ["slime", "skeleton"]
	},
	{
		"name": "5",
		"enemy_count": 100,
		"spawn_interval": 1.0,
		"allowed_mobs": ["skeleton"]
	}
]

func _ready():
	var cursor_texture = load("res://Crosshair/crosshair038.png")
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2(16, 16))
	score_label.text = "0"
	start_wave(0)

func start_wave(wave_index: int):
	if wave_index >= waves.size():
		wave_index = waves.size() - 1

	current_wave = wave_index
	enemies_spawned_in_wave = 0
	alive_enemies = 0
	wave_in_progress = true

	var wave_data = waves[current_wave]
	active_enemy_count = wave_data["enemy_count"]
	active_spawn_interval = wave_data["spawn_interval"]

	spawn_timer.wait_time = active_spawn_interval
	spawn_timer.start()

	wave_label.text = "" + str(current_wave + 1)
	
	#print("Started: ", wave_data["name"])

func spawn_mob():
	var wave_data = waves[current_wave]
	var allowed_mobs = wave_data["allowed_mobs"]

	if allowed_mobs.is_empty():
		return

	var mob_key = allowed_mobs.pick_random()

	if not mob_types.has(mob_key):
		push_warning("Unknown mob type: " + str(mob_key))
		return

	var enemy_scene = mob_types[mob_key]
	var new_mob = enemy_scene.instantiate()

	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)

	alive_enemies += 1

	if new_mob.has_signal("tree_exited"):
		new_mob.tree_exited.connect(_on_enemy_removed)

func _on_timer_timeout():
	if not wave_in_progress:
		return

	if enemies_spawned_in_wave < active_enemy_count:
		spawn_mob()
		enemies_spawned_in_wave += 1
	else:
		spawn_timer.stop()
		check_wave_complete()

func _on_enemy_removed():
	alive_enemies -= 1
	check_wave_complete()

func check_wave_complete():
	if enemies_spawned_in_wave >= active_enemy_count and alive_enemies <= 0:
		wave_in_progress = false
		start_next_wave()

func start_next_wave():
	var next_wave = current_wave + 1

	if next_wave < waves.size():
		start_wave(next_wave)
	else:
		start_endless_wave()

func start_endless_wave():
	current_wave = waves.size() - 1
	enemies_spawned_in_wave = 0
	alive_enemies = 0
	wave_in_progress = true

	var base_wave = waves[waves.size() - 1]
	var endless_level = max(1, int(score / 50))

	active_enemy_count = base_wave["enemy_count"] + endless_level * 2
	active_spawn_interval = max(0.4, base_wave["spawn_interval"] - endless_level * 0.05)

	spawn_timer.wait_time = active_spawn_interval
	spawn_timer.start()

	wave_label.text = "∞"
	#print("Endless scaling wave started")
	#print("Enemy count: ", active_enemy_count)
	#print("Spawn interval: ", active_spawn_interval)

func add_score(amount):
	score += amount
	score_label.text = "" + str(score)

func _on_player_health_depleted():
	%GameOver.visible = true
	get_tree().paused = true
	spawn_timer.stop()

	score = 0
	%ScoreLabel.text = "0"

func _on_back_to_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
