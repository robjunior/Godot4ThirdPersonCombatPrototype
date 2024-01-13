class_name HeadsUpDisplay
extends Control


@export var enabled: bool = true

var _lock_on_target: LockOnComponent = null

var _backstab_victim: BackstabComponent = null
var _previous_backstab_victim: BackstabComponent = null
var _backstab_crosshair_visisble: bool = false

var _saved_dizzy_victim: DizzyComponent

@onready var notice_triangles: Node2D = $NoticeTriangles
@onready var off_camera_notice_triangles: Node2D = $OffCameraNoticeTriangles
@onready var wellbeing_widgets: Node2D = $WellbeingWidgets
@onready var interaction_hints: InteractionHints = $InteractionHints

@onready var _lock_on_texture: TextureRect = $LockOn
@onready var _crosshair: Sprite2D = $Crosshair

@onready var lock_on_system: LockOnSystem = Globals.lock_on_system
@onready var backstab_system: BackstabSystem = Globals.backstab_system
@onready var dizzy_system: DizzySystem = Globals.dizzy_system


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_lock_on_texture.visible = false
	_crosshair.modulate.a = 0.0
	
	lock_on_system.lock_on.connect(
		_on_lock_on_system_lock_on
	)
	
	backstab_system.current_victim.connect(
		_on_backstab_system_current_victim
	)


func _physics_process(_delta: float) -> void:
	
	_process_lock_on()
	_process_backstab()
	_process_dizzy()
	
	if (_backstab_crosshair_visisble and not _previous_backstab_victim) or \
		(dizzy_system.dizzy_victim and dizzy_system.can_kill_victim):
		_crosshair.modulate.a = move_toward(
			_crosshair.modulate.a,
			1.0,
			0.1
		)
	else:
		_crosshair.modulate.a = move_toward(
			_crosshair.modulate.a,
			0.0,
			0.1
		)
	
	_lock_on_texture.visible = _lock_on_target != null
	
	if enabled:
		modulate.a = lerp(
			modulate.a,
			1.0,
			0.1
		)
	else:
		modulate.a = lerp(
			modulate.a,
			0.0,
			0.1
		)


func _on_lock_on_system_lock_on(target: LockOnComponent) -> void:
	_lock_on_target = target


func _process_lock_on() -> void:
	if not _lock_on_target:
		return
	
	var pos: Vector2 = Globals.camera_controller.get_lock_on_position(_lock_on_target)
	var lock_on_pos: Vector2 = Vector2(
		pos.x - _lock_on_texture.size.x / 2,
		pos.y - _lock_on_texture.size.y / 2
	)
	
	_lock_on_texture.position = lock_on_pos


func _process_backstab() -> void:
	if not _backstab_victim:
		return
	
	if dizzy_system.dizzy_victim:
		return
	
	if _previous_backstab_victim and _crosshair.modulate.a < 0.05:
		_previous_backstab_victim = null
		return
	
	var current_focus: BackstabComponent
	if _previous_backstab_victim:
		current_focus = _previous_backstab_victim
	else:
		current_focus = _backstab_victim
	
	var pos: Vector2 = Globals.camera_controller.get_lock_on_position(current_focus)
	var crosshair_pos: Vector2 = Vector2(
		pos.x,
		pos.y
	)
	
	_crosshair.position = crosshair_pos


func _on_backstab_system_current_victim(victim: BackstabComponent) -> void:
	if victim:
		_previous_backstab_victim = _backstab_victim
		_backstab_victim = victim
		_backstab_crosshair_visisble = true
	else:
		_backstab_crosshair_visisble = false


func _process_dizzy() -> void:
	if dizzy_system.dizzy_victim:
		_saved_dizzy_victim = dizzy_system.dizzy_victim
	elif _crosshair.modulate.a < 0.1:
		return
	else:
		_saved_dizzy_victim = null
	
	if _saved_dizzy_victim == null:
		return
	
	var pos: Vector2 = Globals.camera_controller.get_lock_on_position(_saved_dizzy_victim)
	var crosshair_pos: Vector2 = Vector2(
		pos.x,
		pos.y
	)
	
	_crosshair.position = crosshair_pos