extends Area2D
class_name Projectile

# Projectile that travels in a direction and despawns after a distance

@export var speed: float = 400.0
@export var max_range: float = 300.0

var direction: Vector2 = Vector2.RIGHT
var distance_traveled: float = 0.0

func _ready():
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	var movement = direction * speed * delta
	position += movement
	distance_traveled += movement.length()
	
	if distance_traveled >= max_range:
		queue_free()

func _on_body_entered(body):
	# Handle collision with enemies
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(10)
		queue_free()
	elif body.has_method("take_damage"):
		body.take_damage(10)
		queue_free()
