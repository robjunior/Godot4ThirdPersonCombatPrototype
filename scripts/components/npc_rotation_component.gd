class_name NPCRotationComponent
extends RotationComponent


@export var debug: bool = false
@export var movement_component: MovementComponent
@export var blackboard: Blackboard
@export var agent: NavigationAgent3D

var _target_look: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	looking_direction = looking_direction.rotated(Vector3.UP, entity.rotation.y).normalized()

func _physics_process(_delta: float) -> void:
	var _input_direction: Vector3 = blackboard.get_value("input_direction", Vector3.ZERO)
	var _can_move: bool = movement_component.can_move
	var _velocity: Vector3 = movement_component.desired_velocity

#	print(_blackboard.has_value("look_at_target"))
	move_direction = _input_direction
	
	if debug:
		pass

	if look_at_target:
		# get the angle towards the lock on target and
		# smoothyl rotate the player towards it
		var _next_location: Vector3 = agent.get_next_path_position()
		looking_direction = entity.global_position.direction_to(_next_location)
		_target_look = atan2(-looking_direction.x, -looking_direction.z)
		

		var rotation_difference: float = abs(entity.rotation.y - _target_look)

		# This makes the rotation smoother when the player is locked
		# on and transitions from sprinting to walking
		var rotation_weight: float
		if rotation_difference < 0.05:
			rotation_weight = 0.2
		else:
			rotation_weight = 0.1

		entity.rotation.y = lerp_angle(entity.rotation.y, _target_look, rotation_weight)

		# change move direction so it orbits the locked on target
		# (not a perfect orbit, needs tuning but not unplayable)
		if move_direction.length() > 0.2:
			move_direction = move_direction.rotated(
				Vector3.UP,
				_target_look + sign(move_direction.x) * 0.02
			).normalized()
	
	elif _input_direction.length() > 0.2:
		
		looking_direction = lerp(
			Vector3.FORWARD.rotated(
				Vector3.UP,
				get_parent().global_rotation.y
			),
			_input_direction.rotated(
				Vector3.UP,
				get_parent().global_rotation.y
			),
			0.15
		)
		
		_target_look = atan2(-looking_direction.x, -looking_direction.z)
		entity.rotation.y = lerp_angle(entity.rotation.y, _target_look, 0.1)
		
		move_direction = Vector3.ZERO
		
