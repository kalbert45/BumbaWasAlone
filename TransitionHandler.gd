extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# unpause whenever transition finishes
	$AnimationPlayer.connect("animation_finished", self, "unpause")
	
	#when game starts, pause and show beginning text
	get_tree().paused = true


func unpause(animation):
	print('unpause called')
	get_tree().paused = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
