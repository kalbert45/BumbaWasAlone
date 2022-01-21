extends Node

signal land_created(instance)

onready var temp_objects = $TemporaryThings

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func handle_scene_change():
	yield(get_tree().create_timer(1), "timeout")
	temp_objects.queue_free()
	
	# add dry land
	var land = load("res://Land.tscn")
	var land_instance = land.instance()
	add_child(land_instance)
	emit_signal('land_created', land_instance)
	
	# move ocean
	$Ocean0.global_position.y = 540
	
