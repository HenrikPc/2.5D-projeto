class_name MapPlayer
extends CharacterBody3D

const SPEED = 5.0
const INTERACTION_REACH = 1.4

@export var dialogue_box: InteractionMessage
## Horizontal distance from the speaker at which an open conversation ends.
@export_range(1.5, 10.0, 0.1, "or_greater") var dialogue_exit_distance: float = 2.0

var _dialogue_source: WeakRef

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var body_shape: CollisionShape3D = $CollisionShape3D

var idle_clip: StringName = &"idle"
var direcao_anterior: Vector2 = Vector2.ZERO
var facing_direction: Vector3 = Vector3.BACK  # +Z is down on screen.


func _ready() -> void:
	sprite.play(idle_clip)


func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)

	velocity.x = direction.x * SPEED
	velocity.z = direction.y * SPEED

	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
	_check_dialogue_distance()

	if direction != direcao_anterior:
		direcao_anterior = direction
		_update_animation(direction)

	if Input.is_action_just_pressed(&"interact"):
		if dialogue_box != null and dialogue_box.advance_if_open():
			return
		_try_interact()


func start_dialogue(pages: PackedStringArray, source: Node3D = null) -> void:
	if dialogue_box == null or dialogue_box.is_open():
		return
	dialogue_box.show_pages(pages)
	_dialogue_source = weakref(source) if source != null else null


func _check_dialogue_distance() -> void:
	if _dialogue_source == null:
		return
	if dialogue_box.is_open():
		var source: Node3D = _dialogue_source.get_ref() as Node3D
		if source != null and source.is_inside_tree():
			var offset: Vector3 = global_position - source.global_position
			if Vector2(offset.x, offset.z).length_squared() <= dialogue_exit_distance * dialogue_exit_distance:
				return
		dialogue_box.close_dialogue()
	_dialogue_source = null


func _try_interact() -> void:
	var origin: Vector3 = body_shape.global_position
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		origin, origin + facing_direction * INTERACTION_REACH, collision_mask, [get_rid()]
	)
	query.collide_with_areas = true
	# Only the first collider is eligible; solid obstacles block interaction.
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	var target: Object = hit.get("collider") as Object
	if target != null and target.has_method(&"interact"):
		target.call(&"interact", self)


func _update_animation(direction: Vector2) -> void:
	var clip: StringName = idle_clip

	if direction.x != 0.0:
		facing_direction = Vector3.LEFT if direction.x < 0.0 else Vector3.RIGHT
		clip = &"walk_side"
		idle_clip = &"side_idle"
		sprite.flip_h = direction.x < 0.0
	elif direction.y != 0.0:
		var moving_up: bool = direction.y < 0.0
		facing_direction = Vector3.FORWARD if moving_up else Vector3.BACK
		clip = &"walk_up" if moving_up else &"walk_down"
		idle_clip = &"up_idle" if moving_up else &"idle"
		sprite.flip_h = false

	if sprite.animation != clip:
		sprite.play(clip)
