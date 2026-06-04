class_name Hurtbox
extends Area2D

signal hurt
signal die

@export var health: int = 1
@export var invisible_time: float = 1.0

var timer_invisible: float = 0.0
var _is_invisible: bool = false

var is_invisible: bool:
	get:
		return _is_invisible
	set(value):
		_is_invisible = value
		for child in get_children():
			if child is CollisionShape2D:
				child.set_deferred("disabled", value)

func _physics_process(delta: float) -> void:
	if health <= 0:
		return

	if timer_invisible > 0.0:
		timer_invisible -= delta
		if timer_invisible <= 0.0:
			is_invisible = false

func take_damage(value: int) -> void:
	if health <= 0:
		return

	health -= value
	hurt.emit()

	is_invisible = true
	timer_invisible = invisible_time

	if health <= 0:
		is_invisible = true
		monitoring = false
		die.emit()
		queue_free()
