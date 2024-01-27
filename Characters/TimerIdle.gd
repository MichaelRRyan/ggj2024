extends Timer

var rng = RandomNumberGenerator.new()
var random_time = rng.randf_range(-10.0, 10.0)
# Called when the node enters the scene tree for the first time.
func _ready():
	start(random_time)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func _on_timeout():
	random_time = rng.randf_range(0.0, 2.0)
	start(random_time)
	pass # Replace with function body.
