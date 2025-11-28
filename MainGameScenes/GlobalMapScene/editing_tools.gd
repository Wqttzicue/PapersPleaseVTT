extends Control

@onready var color_picker = %ColorPicker

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
			#Appending new point to class
			current_path = PathData.new()
			current_path.points.append(event.position)
			current_path.color = current_color
			current_path.width = current_width
			
			var color_picker_rect = color_picker.get_global_rect()
			if color_picker_rect.has_point(event.position) and color_picker.visible == true:
				return
			else:
				color_picker.set_visible(false)
			
		else:
			if current_path.points.size() > 1:
				paths.append(current_path)
			current_path = null
		is_mouse_pressed = event.is_pressed()
		queue_redraw()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			color_picker.set_visible(true)
		color_picker.get_parent()
	
	if is_mouse_pressed and event is InputEventMouseMotion:
		current_path.points.append(event.position)
		queue_redraw()

func _draw():
	for i in range(paths.size()):
		draw(paths[i])
		
	if current_path:
		draw(current_path)

# Assigning PathData class proper color_pickers n' width_sliders' values
var current_color: Color = Color.BLACK
var current_width: float = 0
func _on_color_picker_color_changed(color: Color):
	current_color = color
func _on_h_slider_value_changed(width: float) -> void:
	current_width = width
