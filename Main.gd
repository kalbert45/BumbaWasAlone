extends Node2D

#variable to store prediction from python script as a string, since lists dont transfer
var prediction_string
# list to hold predictions after string is processed
var prediction = []
# string that contains object to be created
var response_string
# classes that matter out of the 345 available
var relevant_classes = []
# where the drawing is located, calculated by averaging top left and bottom right
var drawing_location = Vector2()
# boolean to hold whether player is in drawing mode
var is_drawing_active = false
# boolean to hold whether the sun is up
var is_there_sun = false
# boolean to hold whether there is dry land
var is_there_land = false
# boolean to hold whether the time button was activated
var time_button_active = false

var land = preload("res://Land.tscn")
var mountain = preload("res://Mountain.tscn")

onready var paint_handler = $Paint/PaintControl
onready var prediction_handler = $Paint/PredictionHandler
onready var sprite_handler = $SpriteHandler
onready var transition_handler = $UIController/TransitionHandler
onready var temp_objects = $SpriteHandler/TemporaryThings

onready var animation_player = $AnimationPlayer
onready var bumba = $Bumba
onready var underwater_sound = $UnderwaterSound
onready var abovewater_sound = $AbovewaterSound
onready var time_button = $UIController/TimeButton



# Called when the node enters the scene tree for the first time.
func _ready():
	time_button.connect("pressed", self, "transition_dry_land")
	animation_player.connect("animation_finished", self, "animation_ended")
	sprite_handler.connect("land_created", self, "assign_land")
	
	relevant_classes = ['sun','moon','mountain', 'cloud', 'rain', 'tree','fish','shark','star','bird', 
	'penguin','sea_turtle','whale','crab',
	'dolphin', 'octopus','snake','spider','scorpion','frog','tiger','bear','bee']
	# play on game start
	underwater_sound.play()
	get_tree().paused = true

func assign_land(instance):
	land = instance
	update_popup('land')

func transition_dry_land():
	is_there_land = true
	sprite_handler.handle_scene_change()

func update_popup(string):
	if string == 'sun':
		$HelpPopup/Popup/RichTextLabel.add_text('\ncloud\nfish\nshark\nbird\npenguin\nmountain\nsea turtle\nwhale\ndolphin\noctopus')
	elif string == 'land':
		$HelpPopup/Popup/RichTextLabel.add_text('\ntree\ncrab\nsnake\nspider\nscorpion\nfrog\ntiger\nbear\nbee')

#check if bumba is underwater
func is_underwater():
	if not is_there_land:
		if bumba.global_position.y < 230:
			return false
	else:
		if bumba.global_position.y < 410:
			return false
	return true
	
# check if drawing is in sky
func is_in_sky(location):
	if not is_there_land:
		if location.y < 180:
			return true
	else:
		if location.y < 360:
			return true
	return false

func animation_ended(animation):
	if animation == 'world_change':
		#$UnderwaterSound.queue_free()
		$SunCreation.queue_free()
		update_popup('sun')
	if animation == 'activate_time_button':
		time_button.mouse_filter = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# change ambience depending on bumba's location
	if is_underwater():
		if underwater_sound.stream_paused:
			underwater_sound.stream_paused = false
			
			abovewater_sound.stop()
	else:
		if not underwater_sound.stream_paused:
			underwater_sound.stream_paused = true
			
			abovewater_sound.play()
		
	
	# if space pressed, activate drawing. If already active, process drawing
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
			paint_handler.mouse_filter = 2
		else:
			is_drawing_active = true
			paint_handler.mouse_filter = 0
		#print(prediction)
	paint_handler.is_drawing_active = is_drawing_active
	
	
# given top predictions, determine relevant ones
func generate_response_string(category):
	if category in relevant_classes:
		return category
	return null
	
#use location and response string to do appropriate animations
func process_response():
	# sun is important
	if response_string == 'sun':
		if not is_there_sun:
			#create sun
			create(null, 'sun')
		else:
			print('sun in wrong location')
	
	# things that can be drawn once there is land (everything except mountain and sun)
	if is_there_land:
		match response_string:
			null:
				print('nothing')
			'bee':
				if is_in_sky(drawing_location):
					create("res://Assets/Sprites/bee.png")
			'bear':
				if land.is_on_dry_land(drawing_location):
					create("res://Assets/Sprites/bear.png")
			'scorpion':
				if land.is_on_land(drawing_location):
					if is_in_sky(drawing_location):
						create("res://Assets/Sprites/scorpion.png")
			'spider':
				if land.is_on_land(drawing_location):
					if is_in_sky(drawing_location):
						create("res://Assets/Sprites/spider.png")
			'tiger':
				if land.is_on_dry_land(drawing_location):
					create("res://Assets/Sprites/tiger.png")
			'snake':
				if land.is_on_dry_land(drawing_location):
					create("res://Assets/Sprites/snake.png")
			'octopus':
				if not is_in_sky(drawing_location):
					create("res://Assets/Sprites/octopus.png")
			'dolphin':
				if not is_in_sky(drawing_location):
					create("res://Assets/Sprites/dolphin.png")
			'frog':
				if land.is_on_land(drawing_location):
					if is_in_sky(drawing_location):
						create("res://Assets/Sprites/frog.png")
			'tree':
				if land.is_on_dry_land(drawing_location):
					create("res://Assets/Sprites/tree.png")
				else:
					print('tree not on land')
			'crab':
				if land.is_on_land(drawing_location):
					create("res://Assets/Sprites/crab.png")
				else:
					print('crab not on land')
			'cloud':
				if is_in_sky(drawing_location):
					if not land.is_on_land(drawing_location):
						create(null, 'cloud')
				else:
					print('clouds in sky only')
			'fish':
				if not is_in_sky(drawing_location):
					create("res://Assets/Sprites/fish.png")
				else:
					print('fish cant fly')
			'shark':
				if not is_in_sky(drawing_location):
					create("res://Assets/Sprites/shark.png")
				else:
					print('sharks cant fly')
			'bird':
				if is_in_sky(drawing_location):
					if not land.is_on_land(drawing_location):
						create("res://Assets/Sprites/bird.png")
				else:
					print('most birds dont swim')
			'penguin':
				if not is_in_sky(drawing_location) or land.is_on_land(drawing_location):
					create("res://Assets/Sprites/penguin.png")
				else:
					print('penguins dont fly')
			'sea_turtle':
				if not is_in_sky(drawing_location):
					create("res://Assets/Sprites/sea_turtle.png")
				else:
					print('turtles dont fly')
			'whale':
				if not is_in_sky(drawing_location):
					create("res://Assets/Sprites/whale.png")
				else:
					print('whales in the sky?')
			_:
				print(response_string+' as other')
	
	# things that can be drawn after sun
	elif is_there_sun:
		match response_string:
			null:
				print('nothing')
			'cloud':
				if is_in_sky(drawing_location):
					create(null, 'cloud')
				else:
					print('clouds in sky only')
			'mountain':
				if drawing_location.y > 360:
					create(null, 'mountain')
			'fish':
				if not is_in_sky(drawing_location):
					create("res://Assets/Sprites/fish.png")
				else:
					print('fish cant fly')
			'shark':
				if not is_in_sky(drawing_location):
					create("res://Assets/Sprites/shark.png")
				else:
					print('sharks cant fly')
			'octopus':
				if not is_in_sky(drawing_location):
					create("res://Assets/Sprites/octopus.png")
			'dolphin':
				if not is_in_sky(drawing_location):
					create("res://Assets/Sprites/dolphin.png")
			'bird':
				if is_in_sky(drawing_location):
					create("res://Assets/Sprites/bird.png")
				else:
					print('most birds dont swim')
			'penguin':
				if not is_in_sky(drawing_location):
					create("res://Assets/Sprites/penguin.png")
				else:
					print('penguins dont fly')
			'sea_turtle':
				if not is_in_sky(drawing_location):
					create("res://Assets/Sprites/sea_turtle.png")
				else:
					print('turtles dont fly')
			'whale':
				if not is_in_sky(drawing_location):
					create("res://Assets/Sprites/whale.png")
				else:
					print('whales in the sky?')
			_:
				print(response_string+' as other')
			
#handle creations!
func create(img_path, object=null):
	match object:
		null:
			var sprite = Sprite.new()
			sprite.texture = load(img_path)
			sprite.global_position = drawing_location
			if is_there_land:
				add_child(sprite)
			else:
				temp_objects.add_child(sprite)
		'sun':
			$SpriteHandler/Sun.global_position = drawing_location
			animation_player.play('world_change')
			is_there_sun = true
		'cloud':
			var sprite = Sprite.new()
			
			var i = randi()%3+1
			match i:
				1:
					sprite.texture = load("res://Assets/Sprites/cloud1.png")
				2:
					sprite.texture = load("res://Assets/Sprites/cloud2.png")
				3:
					sprite.texture = load("res://Assets/Sprites/cloud3.png")
			sprite.global_position = drawing_location
			if is_there_land:
				add_child(sprite)
			else:
				temp_objects.add_child(sprite)
		'mountain':
			var mountain_instance = mountain.instance()
			mountain_instance.global_position = Vector2(drawing_location.x, 0)
			temp_objects.add_child(mountain_instance)
			if not time_button_active:
				animation_player.play("activate_time_button")
				time_button_active = true
