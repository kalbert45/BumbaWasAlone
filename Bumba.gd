extends KinematicBody2D


onready var sprite = $AnimatedSprite

var drawing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.set_animation('touch')
	sprite.set_frame(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if not drawing:
			sprite.play('touch')
			drawing = true
		else:
			sprite.play('touch', true)
			drawing = false
