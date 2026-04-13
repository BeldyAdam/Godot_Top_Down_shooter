extends Area2D

var can_shoot = true

func _process(_delta):
	look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
		can_shoot = false
		$Timer.start()


func shoot():
	const BULLET = preload("res://bullet.tscn")
	var new_bullet = BULLET.instantiate()
	
	new_bullet.global_position = %ShootingPoint.global_position

	var mouse_position = get_global_mouse_position()
	var direction = mouse_position - %ShootingPoint.global_position
	new_bullet.global_rotation = direction.angle()
	
	get_tree().current_scene.add_child(new_bullet)


func _on_timer_timeout():
	can_shoot = true
