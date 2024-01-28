extends Entity
class_name Minion

signal died(name)

@export var speed : float = 300.0
@export var acceleration : float = 300.0
@export var jump_velocity : float = -400.0
@export var health : float = 10
@export var max_health : float = 10
@export var _fall_dmg_thershold : float = 200.0
@export var _fall_dmg_ratio : float = 0.01
@export var has_axe : bool
@export var has_hammer : bool
@export var build_type : PackedScene
@onready var level_parent = get_parent()
var target_array = Array()
var target_array_counter : int = 0
var interact_array = Array()
var interact_array_counter : int = 0
var _prev_velocity := Vector2.ZERO
var _prev_is_on_floor = false
var target
var is_interacting : bool = false
var has_task : bool = false
var is_moving : bool = true
var has_target : bool = false
var target_x : float = 0.0
var target_x_diff : float = 0.0
var rng = RandomNumberGenerator.new()
var random_number = 0.0

var view_array
@onready var view_area = $View
@onready var interact_area = $InteractRange

@onready var harvest_timer = $TimerHarvest

@onready var _pickup_component : PickupComponent = get_node("PickupComponent")
@onready var _animated_sprite : AnimatedSprite2D = get_node("AnimatedSprite2D")


func _ready():
	health = max_health
	$HealthBar.value = health / max_health
	name = Global.minion_names[randi() % Global.minion_names.size()]
	$NameTag.text = name

func _physics_process(delta):
	var direction = 0
	if is_on_floor():
		# Apply air friction
		velocity.x *= _ground_friction
		
		# Take fall damage on ground impact.
		if not _prev_is_on_floor and _prev_velocity.y >= _fall_dmg_thershold:
			take_damage((_prev_velocity.y - _fall_dmg_thershold) * _fall_dmg_ratio)
			print(_prev_velocity)
		
		if not has_target && not is_interacting && not has_target:
			get_view_array()
			for n in view_array.size():
				if has_axe:
					if view_array[n].is_in_group("tree"):
						target = view_array[n]
						has_target = true
						has_task = true
						target_x = view_array[n].get_global_position().x
				if has_hammer:
					if view_array[n].is_in_group("resource"):
						target_array.append(view_array[n])
						target_array_counter += 1
						if target_array.size() >= 3:
							has_target = true
							has_task = true
							target_x = view_array[n].get_global_position().x
							target = view_array[n]
							
				
		
		if has_target && not is_interacting:
			target_x_diff = get_global_position().x - target_x
			print(target_x_diff)
			print(is_interacting)
			if target_x_diff <= 0.0:
				direction = 1
			else:
				direction = -1
		else:
			direction = 0
		
		# Move randomly if no target.
		if has_task && not has_target && not is_interacting:
			if random_number >= 0.0:
				direction = 1
			else:
				direction = -1
		
		# Play ground movement animations.
		if direction != 0:
			_animated_sprite.play("Walk")
			_animated_sprite.flip_h = direction < 0
		else:
			if has_axe:
				_animated_sprite.play("Idle_Axe")
			else:
				_animated_sprite.play("Idle")
	else:
		velocity.y += gravity * delta
		velocity.x *= _air_friction
		_animated_sprite.play("Limp")
		
	if _pickup_component == null or not _pickup_component.is_held():
		velocity.x = clamp(velocity.x + direction * acceleration * delta, -speed, speed)
	
	_prev_velocity = velocity
	_prev_is_on_floor = is_on_floor()
	move_and_slide()


func _on_timer_idle_timeout():
	if not has_target:
		if not is_interacting:
			has_task = not has_task
			random_number = rng.randf_range(-1.0, 1.0)


func _on_interact_range_body_entered(_body):
	if has_target:
		if target.is_in_group("tree"):
			has_target = false
			is_interacting = true
			has_task = true
			harvest_timer.start(3)
		if target.is_in_group("resource"):
			has_target = false
			is_interacting = true
			has_task = true
			harvest_timer.start(3)
			#building


func _on_timer_harvest_timeout():
	if target != null && target.is_in_group("tree"):
		target.chop()
		target.queue_free()
		harvest_timer.stop()
		is_interacting = false
		has_task = false
		has_target = false
		target = null
		reset_bools()
	elif target != null && target.is_in_group("resource"):
		for n in target_array.size():
			target_array[n].queue_free()
		harvest_timer.stop()
		is_interacting = false
		has_task = false
		has_target = false
		target = null
		build_structure()
		reset_bools()
		target_array = []
	else:
		harvest_timer.stop()
		is_interacting = false
		has_task = false
		has_target = false
		reset_bools()

func reset_bools():
	is_interacting = false
	has_task = false
	has_target = false
	target = null

func get_view_array():
	view_array = view_area.get_overlapping_bodies()
	pass
	
func get_interact_array():
	interact_array = interact_area.get_overlapping_bodies()
	pass

func build_structure():
	var structure_instance : Entity = build_type.instantiate() as Entity
	level_parent.add_child(structure_instance)
	structure_instance.position = position
	structure_instance.position.y -= 50
	#structure_instance.position.x += random_number * 10
	pass

func take_damage(amount : float):
	health -= amount
	$HealthBar.value = health / max_health
	if health <= 0:
		_die()

func _die():
	print(name + " has died.")
	emit_signal("died", name)
	queue_free()

func _on_hold_entity_component_entity_held(entity_type):
	if entity_type == EntityType.TOOL:
		has_axe = true


func _on_hold_entity_component_entity_dropped(entity_type):
	if entity_type == EntityType.TOOL:
		has_axe = false
