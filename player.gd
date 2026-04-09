extends CharacterBody2D

signal health_depleted

var health = 100.0
var slime_damage_cooldown = 0.0

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * 600
	move_and_slide()
	
	#if velocity.length() > 0.0:
		#%HappyBoo.play_walk_animation()
	#else:
		#%HappyBoo.play_idle_animation()
		
	var sprite = $HappyBoo/Sprite
	var anim_direction = "south"

	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim_direction = "east"
		elif direction.x < 0:
			anim_direction = "west"
	else:
		if direction.y > 0:
			anim_direction = "south"
		elif direction.y < 0:
			anim_direction = "north"

	if velocity.length() > 0.0:
		var walk_animation = "walk_" + anim_direction
		if sprite.animation != walk_animation:
			sprite.play(walk_animation)
	else:
		var idle_animation = "idle_" + anim_direction
		if sprite.animation != idle_animation:
			sprite.play(idle_animation)
	
	
	if slime_damage_cooldown > 0.0:
		slime_damage_cooldown -= delta
	
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	var touching_slime = false
	
	for mob in overlapping_mobs:
		if mob.scene_file_path == "res://mob.tscn":
			touching_slime = true
			break
	
	if touching_slime and slime_damage_cooldown <= 0.0:
		health -= 10.0
		%HealthBar.value = health
		slime_damage_cooldown = 0.5
		
		if health <= 0.0:
			health_depleted.emit()

func take_damage(amount := 1):
	health -= amount
	%HealthBar.value = health
	
	if health <= 0.0:
		health_depleted.emit()
