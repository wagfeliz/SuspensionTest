extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	#Engine.max_fps=10
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_text("FPS: "+str(Performance.get_monitor(Performance.TIME_FPS)))
	
