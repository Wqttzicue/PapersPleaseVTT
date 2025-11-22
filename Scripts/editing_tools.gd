extends TextureRect
var width := 10 # TODO нужно будет сделать возможность выбирать жирный текст
var picked_color := Color.GREEN # TODO нужно будет сделать выбор цвета
func draw():
	var pointer := Vector2(get_viewport().get_mouse_position()) # TODO не ебу , мне грок посоветовал viewport, но наверное можно через _input сделать, только я слишком тупой для этого...
	if pointer != null:
		draw_circle(pointer, width, picked_color, true)
	else:
		return

func _process(delta: float):
		queue_redraw()

func _draw():
	if Input.is_action_pressed("LMB"):
		print("drawing..")
		draw()
	print("_draw is working")
	
