extends CharacterBody2D

@export var speed := 200.0
@export var attack_range := 100.0

var health := 3
var is_dead := false
var is_attacking := false

@onready var player = get_node("/root/Game/Player")
@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("walk")

func _physics_process(delta):
	if is_dead:
		return

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = global_position.direction_to(player.global_position)
	var distance = global_position.distance_to(player.global_position)

	sprite.flip_h = direction.x < 0

	if distance <= attack_range:
		velocity = Vector2.ZERO
		move_and_slide()
		start_attack()
		return

	velocity = direction * speed
	move_and_slide()

	if sprite.animation != "walk":
		sprite.play("walk")

func start_attack():
	if is_dead:
		return
	if is_attacking:
		return

	is_attacking = true
	sprite.play("attack")

func take_damage():
	if is_dead:
		return

	health -= 1

	if health > 0:
		sprite.play("hurt")
	else:
		die()

func die():
	is_dead = true
	is_attacking = false
	velocity = Vector2.ZERO
	sprite.play("death")

	var game = get_node("/root/Game")
	if game.has_method("add_score"):
		game.add_score(10)

func try_damage_player():
	if player == null:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance <= attack_range:
		if player.has_method("take_damage"):
			player.take_damage(1)

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "attack" and not is_dead:
		try_damage_player()
		is_attacking = false

	elif sprite.animation == "hurt" and not is_dead:
		is_attacking = false
		sprite.play("walk")

	elif sprite.animation == "death":
		queue_free()
