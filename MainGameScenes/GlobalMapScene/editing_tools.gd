extends Node2D

var color_picker = load("res://MainGameScenes/GlobalMapScene/ColorPickerMenu/color_picker_menu.tscn").instantiate()

# ARRAY OF ARRAYS \/
var paths : Array[PathData]
var current_path: PathData = null
var is_mouse_pressed = false 

func draw(path : PathData):
	if path.points.size() > 1:
		draw_polyline(path.points, path.color, path.width)

func _input(event : InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			current_path = PathData.new()
			current_path.points.append(event.position)
			var color_picker_rect = color_picker.get_global_rect()
			if color_picker_rect.has_point(event.position):
				return
			else:
				remove_child(color_picker)
			
		else:
			if current_path.points.size() > 1:
				paths.append(current_path)
			current_path = null
		is_mouse_pressed = event.is_pressed()
		queue_redraw()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			add_child(color_picker)
		color_picker.get_parent()
	
	if is_mouse_pressed and event is InputEventMouseMotion:
		current_path.points.append(event.position)
		queue_redraw()

func _draw():
	for i in range(paths.size()):
		draw(paths[i])
		
	if current_path:
		draw(current_path)
