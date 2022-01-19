extends KinematicBody2D

const LERP_RATE = 0.005

onready var sprite = $AnimatedSprite

var is_drawing = false
var mouse_pos = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.set_animation('touch')
	sprite.set_frame(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# move bumba to mouse when not drawing
	if not is_drawing:
		mouse_pos = get_viewport().get_mouse_position()
		self.global_position = lerp(self.global_position, mouse_pos, LERP_RATE)
		
	if Input.is_action_just_pressed("ui_accept"):
		if not is_drawing:
			sprite.play('touch')
			is_drawing = true
		else:
			sprite.play('touch', true)
			is_drawing = false
			
	
