extends Node2D


const SHAKE_AMOUNT = 2

var shake = false

onready var animation_player = $AnimationPlayer
onready var sprite = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.connect("animation_finished", self, "end_shake")
	shake = true

func end_shake(_animation):
	shake = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shake:
		sprite.set_offset(Vector2(rand_range(-1.0,1.0)*SHAKE_AMOUNT, rand_range(-1.0,1.0)*SHAKE_AMOUNT))
	else:
		sprite.set_offset(Vector2(0,0))
