@tool
extends SubViewport
func _process(_delta):
	for child in get_children():
		if child.get('size'):
			size = child.size
		if child.get('bleed'):
			size += Vector2i.ONE * (child.bleed * 2)
