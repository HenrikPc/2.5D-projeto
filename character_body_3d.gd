class_name MapPlayer
extends CharacterBody3D

const SPEED = 5.0

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

var idle_clip: StringName = &"idle"
var direcao_anterior := Vector2.ZERO


func _ready() -> void:
	sprite.play(idle_clip)


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)

	velocity.x = direction.x * SPEED
	velocity.z = direction.y * SPEED

	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

	if direction != direcao_anterior:
		direcao_anterior = direction
		_update_animation(direction)


func _update_animation(direction: Vector2) -> void:
	var clip: StringName = idle_clip

	if direction.x != 0.0:
		clip = &"walk_side"
		idle_clip = &"side_idle"
		sprite.flip_h = direction.x < 0.0
	elif direction.y != 0.0:
		var moving_up := direction.y < 0.0
		clip = &"walk_up" if moving_up else &"walk_down"
		idle_clip = &"up_idle" if moving_up else &"idle"
		sprite.flip_h = false

	if sprite.animation != clip:
		sprite.play(clip)
