extends Node2D

const SKY_THRESHOLD = 180

var prediction_string
var prediction = []
var response_string
var relevant_classes = []
var drawing_location = Vector2()
var is_drawing_active = false

onready var paint_handler = $Paint/PaintControl
onready var prediction_handler = $Paint/PredictionHandler


# Called when the node enters the scene tree for the first time.
func _ready():
	relevant_classes = ['sun','moon','mountain', 'tree','grass','fish','shark','star']


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if is_drawing_active:
		
			#save drawing
			paint_handler.get_picture()
			#wait for png to save
			yield(paint_handler, "png_saved_signal")
			#get location of drawing
			drawing_location = paint_handler.img_center
			#get top 5 predictions from model
			prediction_string = prediction_handler.predict()
			#process string
			prediction_string.erase(prediction_string.length()-1, 1)
			prediction = prediction_string.split(",")
			for category in prediction:
				category.erase(0,2)
				category.erase(category.length()-1, 1)
				response_string = generate_response_string(category)
				if response_string != null:
					break
					
					
			#process response
			process_response()
		
			is_drawing_active = false
		else:
			is_drawing_active = true
		#print(prediction)
	paint_handler.is_drawing_active = is_drawing_active
	
	
# given top predictions, determine relevant ones
func generate_response_string(category):
	if category in relevant_classes:
		return category
	return null
	
func is_in_sky(location):
	if location.y < SKY_THRESHOLD:
		return true
	return false
	
#use location and response string to do appropriate animations
func process_response():
	match response_string:
		null:
			print('nothing')
		'sun':
			if is_in_sky(drawing_location):
				print('sun!')
			else:
				print('sun in wrong location')
		_:
			print('other')
