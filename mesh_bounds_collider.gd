@tool
class_name MeshBoundsCollider
extends CollisionShape3D

@onready var source_mesh := get_node_or_null("../..") as MeshInstance3D
var fitted_box: BoxShape3D

func _ready() -> void:
	_sync_bounds()

	# No editor, atualiza a colisão quando você altera a malha do chão.
	if Engine.is_editor_hint() and source_mesh != null and source_mesh.mesh != null:
		source_mesh.mesh.changed.connect(_sync_bounds)

func _sync_bounds() -> void:
	if source_mesh == null or source_mesh.mesh == null:
		shape = null
		return

	var bounds := source_mesh.get_aabb()

	if fitted_box == null:
		fitted_box = BoxShape3D.new()

	fitted_box.size = bounds.size
	position = bounds.get_center()
	shape = fitted_box
