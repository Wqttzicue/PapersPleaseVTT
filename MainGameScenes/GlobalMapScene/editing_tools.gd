extends Control

@onready var color_picker = %ColorPicker

# ARRAY OF ARRAYS \/
var paths : Array[PathData]
var current_path: PathData = null
var is_mouse_pressed = false

# "Kept min_distance to filter points, which helps reduce density and prevents excessive sharpness from micro-movements."
var min_distance: float = 5.0  # Minimum distance between points to add a new one

# "Renamed draw to draw_path for clarity and added logic to use smoothed points if available, falling back to generating them on the fly for real-time smoothing during drawing."
func draw_path(path : PathData):
	if path.points.size() > 1:
		var to_draw = path.smoothed_points if not path.smoothed_points.is_empty() else generate_smoothed_points(path.points)
		draw_polyline(to_draw, path.color, path.width, true)  # Enable antialiasing for smoother lines

func _input(event : InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			# Appending new point to class
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
				# Moved smoothing to be computed and cached on path completion, allowing raw points during input but smoothed rendering always.
				current_path.smoothed_points = generate_smoothed_points(current_path.points)
				paths.append(current_path)
			current_path = null
		is_mouse_pressed = event.is_pressed()
		queue_redraw()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			color_picker.set_visible(true)
			color_picker.get_parent()
	
	if is_mouse_pressed and event is InputEventMouseMotion:
		# Kept distance check to append only significant points, aiding in smoother overall paths by reducing noise.
		if current_path.points.size() > 0 and current_path.points.back().distance_to(event.position) >= min_distance:
			current_path.points.append(event.position)
		queue_redraw()

func _draw():
	for i in range(paths.size()):
		draw_path(paths[i])
	if current_path:
		draw_path(current_path)

# Assigning PathData class proper color_pickers n' width_sliders' values
var current_color: Color = Color.BLACK
var current_width: float = 5.0

func _on_color_picker_color_changed(color: Color):
	current_color = color

func _on_h_slider_value_changed(width: float) -> void:
	current_width = width

# Debug Menu
func _on_button_pressed():
	paths.clear()

# Renamed and modified to generate_smoothed_points as a utility function that returns interpolated points without modifying the original,
# enabling real-time rendering of smooth curves to mimic Krita's stabilizer effect by showing curved lines even during drawing.
func generate_smoothed_points(raw_points: Array[Vector2]) -> Array[Vector2]:
	if raw_points.size() < 4:
		return raw_points.duplicate()  # Return copy to avoid modifying original
	
	var smoothed_points: Array[Vector2] = []
	# Adjusted tension to 1.0 for tighter curves, reducing potential overshoot in sharp direction changes,
	# making it more similar to Krita's weighted or stabilizer modes which control smoothness without excessive wiggling.
	var tension: float = 1.0  # Higher tension for tighter fit to points
	
	for i in range(raw_points.size() - 1):
		var p0 = raw_points[max(0, i - 1)]
		var p1 = raw_points[i]
		var p2 = raw_points[i + 1]
		var p3 = raw_points[min(raw_points.size() - 1, i + 2)]
		
		# "Increased sampling density by sampling every 1 pixel instead of 2, for finer curves that better round sharp corners."
		var segment_length = p1.distance_to(p2)
		var steps = max(1, int(segment_length / 1.0))  # Finer sampling
		
		for step in range(steps + 1):
			var t = float(step) / steps
			var t2 = t * t
			var t3 = t2 * t
			
			var c0 = -tension * t3 + 2 * tension * t2 - tension * t
			var c1 = (2 - tension) * t3 + (tension - 3) * t2 + 1
			var c2 = (tension - 2) * t3 + (3 - 2 * tension) * t2 + tension * t
			var c3 = tension * t3 - tension * t2
			
			var x = c0 * p0.x + c1 * p1.x + c2 * p2.x + c3 * p3.x
			var y = c0 * p0.y + c1 * p1.y + c2 * p2.y + c3 * p3.y
			smoothed_points.append(Vector2(x, y))
	
	# "Removed duplicate points at segment junctions if any, to clean up the polyline."
	if smoothed_points.size() > 1:
		var unique_smoothed: Array[Vector2] = [smoothed_points[0]]
		for i in range(1, smoothed_points.size()):
			if smoothed_points[i] != unique_smoothed.back():
				unique_smoothed.append(smoothed_points[i])
		return unique_smoothed
	return smoothed_points
