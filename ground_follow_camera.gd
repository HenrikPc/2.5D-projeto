class_name GroundFollowCamera
extends Camera3D

## Controls only this orthographic gameplay camera. Other current cameras are independent.
enum EdgeBehavior { KEEP_PLAYER_CENTERED, STOP_AT_TERRAIN_EDGE }

## The point to put at screen center. The map uses a marker at the center of the character art.
@export var target: Node3D
@export var ground: MeshInstance3D
## Centered mode keeps the configured zoom even when the view extends past the ground.
@export var edge_behavior: EdgeBehavior = EdgeBehavior.KEEP_PLAYER_CENTERED

var _height_above_ground: float
var _normal_size: float

func _ready() -> void:
	if target == null or ground == null or ground.mesh == null or projection != PROJECTION_ORTHOGONAL:
		push_warning("GroundFollowCamera requires a target, a ground mesh, and orthographic projection.")
		set_physics_process(false)
		return
	_height_above_ground = ground.to_local(get_camera_transform().origin).y - ground.get_aabb().end.y
	_normal_size = size
	_follow()

func _physics_process(_delta: float) -> void:
	_follow()

func _follow() -> void:
	var bounds: AABB = ground.get_aabb()
	var axes: Basis = ground.global_basis.inverse() * global_basis.orthonormalized()
	var forward: Vector3 = -axes.z
	if forward.y >= -0.00001 or bounds.size.x <= 0.0 or bounds.size.z <= 0.0:
		return

	var focus: Vector3 = ground.to_local(target.global_position)
	var center: Vector3 = focus + forward * ((bounds.end.y - focus.y) / forward.y)
	var view_size: float = _normal_size
	if edge_behavior == EdgeBehavior.STOP_AT_TERRAIN_EDGE:
		var screen: Vector2 = get_viewport().get_visible_rect().size
		if screen.x <= 0.0 or screen.y <= 0.0:
			return
		var right: Vector3 = axes.x - forward * (axes.x.y / forward.y)
		var up: Vector3 = axes.y - forward * (axes.y.y / forward.y)
		var aspect: Vector2 = screen / (screen.y if keep_aspect == KEEP_HEIGHT else screen.x)
		var span: Vector3 = right.abs() * aspect.x + up.abs() * aspect.y
		# Fit an oversized viewport once per layout, never according to player position.
		view_size = minf(_normal_size, minf(bounds.size.x / span.x, bounds.size.z / span.z))
		var half_view: Vector3 = span * (view_size * 0.5)
		center.x = clampf(center.x, bounds.position.x + half_view.x, bounds.end.x - half_view.x)
		center.z = clampf(center.z, bounds.position.z + half_view.z, bounds.end.z - half_view.z)
	if not is_equal_approx(size, view_size):
		size = view_size
	var eye: Vector3 = center + forward * (_height_above_ground / forward.y)
	global_position = ground.to_global(eye - axes.x * h_offset - axes.y * v_offset)
