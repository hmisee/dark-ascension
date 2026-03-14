extends Area2D
class_name EnemyProjectile

# Enemy projectile that damages the player

@export var speed: float = 250.0
@export var max_range: float = 400.0
@export var damage: float = 10.0

var direction: Vector2 = Vector2.RIGHT
var distance_traveled: float = 0.0

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta):
	var movement = direction * speed * delta
	position += movement
	distance_traveled += movement.length()
	
	if distance_traveled >= max_range:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.call_deferred("take_damage", damage)
		call_deferred("queue_free")
	elif body.is_in_group("shadow"):
		if body.has_method("take_damage"):
			body.call_deferred("take_damage", damage)
		call_deferred("queue_free")

func _on_area_entered(area):
	# Don't collide with other enemy projectiles
	if area is EnemyProjectile:
		return
	queue_free()
