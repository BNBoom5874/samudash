class_name Hitbox
extends Area2D

signal Hit


var is_active : bool = false : set = set_active


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func set_active(value: bool) -> void:
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", !value)


func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		print("area entered: ", area.name)
		area.take_damage(1)
		Hit.emit()
	
