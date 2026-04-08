extends Area2D

var target_enemy = null

func _process(_delta):
	var enemies = get_overlapping_bodies()
	
	if enemies.size() > 0:
		target_enemy = enemies.front()
		look_at(target_enemy.global_position)
	else:
		target_enemy = null


func shoot():
	const BULLET = preload("res://bullet.tscn")
	var new_bullet = BULLET.instantiate()
	
	new_bullet.global_transform = %ShootingPoint.global_transform
	new_bullet.global_rotation = %ShootingPoint.global_rotation
	
	%ShootingPoint.add_child(new_bullet)


func _on_timer_timeout():
	if target_enemy:
		shoot()
