extends Control

# image size normalized for CNN classification
const IMAGE_SIZE = Vector2(256, 256)
const BRUSH_SIZE = 2
const BRUSH_COLOR = Color.black

signal png_saved_signal

var viewport_size = Vector2()

# picture for use in model prediction
var picture

# center of image
var img_center = Vector2()

# A list to hold the dictionary that makes up the brush
var brush_data_list = []

#boolean to hold when drawing is active
# and position of mouse when left click was pressed
var is_drawing_active = false
var last_mouse_pos = Vector2()

#boolean to check if mouse is in window
var mouse_in_window = false

#booleans to hold when a stroke is being drawn and to hold whether the first
#of the drawing occurred
var drawing_line = false
var first_click = false

#hidden canvas rectangle for processing image
onready var hidden_canvas = $ViewportContainer/Viewport/ColorRect

#position nodes for cropping
onready var TL_node = $TLPos
onready var BR_node = $BRPos

# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_size = get_viewport().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): 
	#share brush list with ColorRect node
	hidden_canvas.brush_data_list = brush_data_list
	
	#for testing
	if Input.is_action_just_pressed("ui_accept"):
		#get_picture()
		first_click = false
		brush_data_list = []
		update()
		hidden_canvas.update()
	
	var mouse_pos = get_viewport().get_mouse_position()
	
	#check if mouse is in window
	mouse_in_window = false
	if mouse_pos.x < viewport_size.x and mouse_pos.x > 0:
		if mouse_pos.y < viewport_size.y and mouse_pos.y > 0:
			mouse_in_window = true
			
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and mouse_in_window:
		#for the first click, set TL and BR nodes to mouse position
		if not first_click:
			TL_node.global_position = mouse_pos
			BR_node.global_position = mouse_pos
			first_click = true
			
		drawing_line = true
		
		if is_drawing_active:
			#draw so long as mouse is not still
			if mouse_pos.distance_to(last_mouse_pos) >= 1:
				add_brush(mouse_pos, false)
				
			#update TL and BR node positions
			if TL_node.global_position.x > mouse_pos.x:
				TL_node.global_position.x = mouse_pos.x
			if TL_node.global_position.y > mouse_pos.y:
				TL_node.global_position.y = mouse_pos.y
			if BR_node.global_position.x < mouse_pos.x:
				BR_node.global_position.x = mouse_pos.x
			if BR_node.global_position.y < mouse_pos.y:
				BR_node.global_position.y = mouse_pos.y
	else:
		if drawing_line:
			if is_drawing_active:
				add_brush(mouse_pos, true)
		drawing_line = false
		#mouse_click_start_pos = null
		
	last_mouse_pos = mouse_pos
	

func add_brush(mouse_pos, end_line):
	var new_brush = {}
	
	new_brush.brush_pos = mouse_pos
	new_brush.end_line = end_line
	
	# Get the center point inbetween the mouse position and the position of the mouse when we clicked.
	#var center_pos = Vector2((mouse_pos.x + mouse_click_start_pos.x) / 2, (mouse_pos.y + mouse_click_start_pos.y) / 2)
	#new_brush.brush_pos = center_pos
	#new_brush.brush_shape_circle_radius = center_pos.distance_to(Vector2(center_pos.x, mouse_pos.y))
	
	brush_data_list.append(new_brush)
	update()
	hidden_canvas.update()
	
	
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
				
func get_picture():
	yield(VisualServer, "frame_post_draw")
	#print('get picture called')
	#get viewport image from hidden canvas
	var img = $ViewportContainer/Viewport.get_texture().get_data()
	# unflip image (flipped by default)
	img.flip_y()
	#crop using TL and BR nodes
	var img_size = Vector2()
	img_size.x = BR_node.global_position.x - TL_node.global_position.x
	img_size.y = BR_node.global_position.y - TL_node.global_position.y
	var cropped_img = img.get_rect(Rect2(TL_node.global_position, img_size))
	
	#get center of image
	img_center.x = (BR_node.global_position.x + TL_node.global_position.x)/2
	img_center.y = (BR_node.global_position.y + TL_node.global_position.y)/2
	
	cropped_img.save_png('img.png')
	emit_signal('png_saved_signal')
