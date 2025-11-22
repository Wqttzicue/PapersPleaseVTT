extends TextureRect
var draw_data := DrawData.new()

func _process(delta):
	if Input.is_action_pressed("LMB"):
		queue_redraw()

func _draw():
	var pointer := Vector2(get_viewport().get_mouse_position())
	if Input.is_action_pressed("LMB"):
		draw_data.colored_points.append(pointer)
		draw_polygon(draw_data.colored_points, [draw_data.color])
