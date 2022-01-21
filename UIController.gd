extends Node



onready var begin_button = $Menu/Control/BeginButton
onready var exit_button = $Menu/Control/ExitButton
onready var time_button = $TimeButton

onready var transition_handler = $TransitionHandler

# Called when the node enters the scene tree for the first time.
func _ready():
	begin_button.connect("pressed", self, 'begin_button_pressed')
	exit_button.connect("pressed", self, "exit_button_pressed")
	time_button.connect("pressed", self, "time_button_pressed")
	
func time_button_pressed():
	$TimeButton.queue_free()
	transition_handler.dry_land_transition()


func begin_button_pressed():
	$Menu.queue_free()
	transition_handler.beginning_transition()
	
func exit_button_pressed():
	get_tree().quit()
