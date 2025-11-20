extends TextureRect
var width := 0.0 # TODO нужно будет сделать возможность выбирать жирный текст
var picked_color = null # TODO нужно будет сделать выбор цвета
func draw():
	var pointer := Vector2(get_viewport().get_mouse_position()) # TODO не ебу , мне грок посоветовал viewport, но наверное можно через _input сделать, только я слишком тупой для этого...
	if pointer != null:
		draw_circle(pointer, width, picked_color, true)
	else:
		return
