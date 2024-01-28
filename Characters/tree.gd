extends StaticBody2D

@export var resource_type : PackedScene

@onready var level_parent = get_parent()

func chop():
	print("chopped")
	spawn_resource()

func spawn_resource():
	for n in 3:
		var resource_instance : Entity = resource_type.instantiate() as Entity
		level_parent.add_child(resource_instance)
		resource_instance.position = position
		resource_instance.position.y -= 30 * n
