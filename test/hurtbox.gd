class_name Hurtbox
extends Area2D

signal hurt
signal die

@export var health : int = 1

const Time_invisible : float = 1.0

var is_invisible : bool = false : set = set_invisible


func set_invisible(value: bool) -> void:
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", value)






func take_damage(value: int):
	health -= value
	hurt.emit()
	
	if health <= 0:
		die.emit()
