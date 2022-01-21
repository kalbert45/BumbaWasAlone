extends Node2D


onready var dry_land_polygon = $DryLand
onready var all_land_polygon = $AllLand


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func is_on_dry_land(location):
	var polygon = dry_land_polygon.get_polygon()
	return Geometry.is_point_in_polygon(location-dry_land_polygon.global_position, polygon)
	
func is_on_land(location):
	var polygon = all_land_polygon.get_polygon()
	return Geometry.is_point_in_polygon(location-all_land_polygon.global_position, polygon)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
