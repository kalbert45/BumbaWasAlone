extends ColorRect


const BRUSH_SIZE = 2
const BRUSH_COLOR = Color.black

var brush_data_list = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	var last_brush_pos = null
	# Go through brushes
	for brush in brush_data_list:
		if last_brush_pos == null:
			# Simply draw circle
			draw_circle(brush.brush_pos, BRUSH_SIZE/2, BRUSH_COLOR)
			last_brush_pos = brush.brush_pos
		else:
			# draw a line and circle
			draw_circle(brush.brush_pos, BRUSH_SIZE/2, BRUSH_COLOR)
			draw_line(last_brush_pos, brush.brush_pos, BRUSH_COLOR, BRUSH_SIZE)
			if brush.end_line:
				last_brush_pos = null
			else:
				last_brush_pos = brush.brush_pos
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
