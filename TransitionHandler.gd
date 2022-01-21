extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	# unpause whenever transition finishes
	animation_player.connect("animation_finished", self, "unpause")
	

func beginning_transition():
	get_tree().paused = true
	animation_player.play('beginning_transition')
	
func dry_land_transition():
	get_tree().paused = true
	animation_player.play('dry_land_transition')

func unpause(_animation):
	print('unpause called')
	get_tree().paused = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
