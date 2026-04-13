extends Area2D

var speed = 1000
var lifetime = 1.5

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()
	

func _physics_process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage()

	queue_free()
