@tool
class_name InteractionMessage
extends CanvasLayer

const SCREEN_MARGIN = 16.0

@export_group("Box Layout")
## Width used for short messages. Limited by Maximum Width and the screen edges.
@export_range(64, 1600, 1, "or_greater", "suffix:px") var minimum_width: int = 256:
	set(value):
		minimum_width = value
		_refresh_layout()
## Long text expands up to this width before wrapping. Leave room at both screen edges.
@export_range(64, 2048, 1, "or_greater", "suffix:px") var maximum_width: int = 1024:
	set(value):
		maximum_width = value
		_refresh_layout()
## Fixed height including padding. Always allows at least one line of the chosen font.
## If more lines are needed, E continues the same message in the same box.
@export_range(32, 360, 1, "or_greater", "suffix:px") var box_height: int = 92:
	set(value):
		box_height = value
		_refresh_layout()
## Distance between the box and the bottom edge of the screen.
@export_range(0, 240, 1, "or_greater", "suffix:px") var bottom_margin: int = 40:
	set(value):
		bottom_margin = value
		_refresh_layout()

@export_group("Typography")
## Drop a Font resource here. Leave empty to use the theme font.
@export var dialogue_font: Font:
	set(value):
		dialogue_font = value
		_refresh_layout()
@export_range(8, 96, 1, "or_greater", "suffix:px") var font_size: int = 24:
	set(value):
		font_size = value
		_refresh_layout()
## Extra space between words, not letters. Zero preserves the font's original spacing.
@export_range(-2, 24, 1, "or_greater", "suffix:px") var word_spacing: int = 0:
	set(value):
		word_spacing = value
		_refresh_layout()

@export_group("Editor Preview")
## Show a sample in the 2D editor while tuning the box. Never displayed in the game.
@export var show_preview: bool = false:
	set(value):
		show_preview = value
		_refresh_layout()
@export_multiline var preview_text: String = "Trilha da Forja — Siga pela estrada até encontrar a forja.":
	set(value):
		preview_text = value
		_refresh_layout()

@onready var notice: Label = $Notice

var _theme_font: Font
var _styled_font: FontVariation = FontVariation.new()
var _preview: Label
var _pages: PackedStringArray = PackedStringArray()
var _page_index: int = 0


func _ready() -> void:
	_theme_font = notice.get_theme_font(&"font")
	get_viewport().size_changed.connect(_refresh_layout)
	_refresh_layout()


func _refresh_layout() -> void:
	if not is_instance_valid(notice) or _theme_font == null:
		return
	var label: Label = notice
	if Engine.is_editor_hint():
		if not show_preview:
			if is_instance_valid(_preview):
				_preview.hide()
				_preview.queue_free()
				_preview = null
			return
		if not is_instance_valid(_preview):
			# A transient copy avoids saving sample text or font overrides on the real Notice.
			_preview = notice.duplicate(0) as Label
			add_child(_preview, false, Node.INTERNAL_MODE_BACK)
		label = _preview
		label.text = preview_text
		label.show()
	elif not is_open():
		return

	_styled_font.base_font = dialogue_font if dialogue_font != null else _theme_font
	_styled_font.spacing_space = word_spacing
	label.add_theme_font_override(&"font", _styled_font)
	label.add_theme_font_size_override(&"font_size", font_size)
	var screen: Vector2 = label.get_parent_area_size()
	var padding: Vector2 = label.get_theme_stylebox(&"normal").get_minimum_size()
	var natural_width: float = _styled_font.get_multiline_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var cap: float = maxf(1.0, minf(maximum_width, screen.x - SCREEN_MARGIN * 2.0))
	var width: float = clampf(ceilf(natural_width) + padding.x + 1.0, minf(minimum_width, cap), cap)
	label.offset_left = floorf(-width * 0.5)
	label.offset_right = label.offset_left + width
	var height: float = minf(screen.y, maxf(box_height, padding.y + label.get_line_height()))
	var gap: float = clampf(bottom_margin, 0.0, maxf(0.0, screen.y - height))
	label.offset_top = -gap - height
	label.offset_bottom = -gap
	# Reflow from the start of this authored page after a resize; never skip unseen text.
	label.lines_skipped = 0


func show_pages(pages: PackedStringArray) -> void:
	if is_open():
		return
	for page: String in pages:
		if not page.strip_edges().is_empty():
			_pages.append(page)
	if is_open():
		_page_index = 0
		_show_current_page()


func _show_current_page() -> void:
	notice.text = _pages[_page_index]
	_refresh_layout()
	notice.show()


## E reveals overflow lines before advancing to the next authored page.
func advance_if_open() -> bool:
	if not is_open():
		return false
	var next_line: int = notice.lines_skipped + maxi(1, notice.get_visible_line_count())
	if next_line < notice.get_line_count():
		notice.lines_skipped = next_line
		return true
	_page_index += 1
	if _page_index < _pages.size():
		_show_current_page()
	else:
		close_dialogue()
	return true


func is_open() -> bool:
	return not _pages.is_empty()


func close_dialogue() -> void:
	_pages.clear()
	_page_index = 0
	notice.hide()
	notice.lines_skipped = 0
	notice.text = ""
