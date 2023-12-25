class_name PlayerRunState
extends PlayerStateMachine


@export var idle_state: PlayerIdleState
@export var walk_state: PlayerWalkState
@export var jump_state: PlayerJumpState
@export var dodge_state: PlayerDodgeState
@export var attack_state: PlayerAttackState
@export var block_state: PlayerBlockState


func enter() -> void:
	player.movement_component.speed = 5


func process_player() -> void:
	if player.input_direction.length() < 0.2:
		parent_state.change_state(idle_state)
		return
	
	if not player.holding_down_run:
		parent_state.change_state(walk_state)
		return
	
	if Input.is_action_just_pressed("run"):
		parent_state.change_state(dodge_state)
		return
	
	if Input.is_action_just_pressed("jump") and \
	player.is_on_floor():
		parent_state.change_state(jump_state)
		return
	
	if Input.is_action_just_pressed("attack"):
		parent_state.change_state(attack_state)
		return
	
	if Input.is_action_pressed("block") and (
		not player.attack_component.attacking or \
		player.attack_component.stop_attacking()
	):
		parent_state.change_state(block_state)
		return
	
	
	player.set_rotation_target_to_lock_on_target()
	
	if player.lock_on_target and player.input_direction.z <= 0:
		player.rotation_component.rotate_towards_target = true
	else:
		player.rotation_component.rotate_towards_target = false