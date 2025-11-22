extends TextureRect
# ARRAY OF ARRAYS \/
var paths : Array[PathData]
var current_path: PathData = null
var is_mouse_pressed = false 

func draw(path : PathData):
	draw_polyline(path.points, path.color, path.width)

func _input(event : InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			current_path = PathData.new()
			current_path.points.append(event.position)
		else:
			paths.append(current_path)
			current_path = null
		is_mouse_pressed = event.is_pressed()
		queue_redraw()
		
	if is_mouse_pressed and event is InputEventMouseMotion:
		current_path.points.append(event.position)
		queue_redraw()

func _draw():
	for i in range(paths.size()):
		draw(paths[i])
		
	if current_path:
		draw(current_path)
