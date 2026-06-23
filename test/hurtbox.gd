class_name Hurtbox
extends Area2D

signal hurt
signal die

@export var health: int = 1
@export var invisible_time: float = 1.0

var timer_invisible: float = 0.0
var is_active: bool = true : set = set_active




func set_active(value: bool) -> void:
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", !value)


func take_damage(value: int) -> void:
	if health <= 0:
		return
	
	if not is_instance_valid(self):
		return
	
	health -= value
	hurt.emit()


	timer_invisible = invisible_time

	if health <= 0:
		is_active = false
		monitoring = false
		die.emit()
		queue_free()
