class_name TrailSign
extends StaticBody3D

## First page. With no additional pages, the next press closes this message.
@export_multiline var message: String = ""
## Optional continuation, one text box per entry, in reading order.
@export_multiline var additional_pages: PackedStringArray = PackedStringArray()


func interact(player: MapPlayer) -> void:
	var pages: PackedStringArray = PackedStringArray([message])
	pages.append_array(additional_pages)
	player.start_dialogue(pages, self)
