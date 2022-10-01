class_name Enemy
extends KinematicBody2D

const KNOCKBACK_DISTANCE := Vector2(100, 0)

var target : Player
var _should_move := true

export var speed := 175
export var health := 6

onready var _tween = $Tween as Tween


func _physics_process(delta:float)->void:
	if _should_move:
		if _can_see_target():
			look_at(target.global_position)
			
			var movement_direction := Vector2.RIGHT.rotated(rotation)
			
			# warning-ignore:return_value_discarded
			move_and_collide(movement_direction * speed * delta)


func _can_see_target()->bool:
	var intersection := get_world_2d().direct_space_state.intersect_ray(global_position, target.global_position, [self])
	if intersection.size() > 0:
		return intersection.collider == target
	else:
		return false


func hit(damage:int)->void:
	health -= damage
	_knockback()


func _knockback()->void:
	_should_move = false
	_tween.interpolate_property(self, "position", null, position + KNOCKBACK_DISTANCE.rotated(rotation + PI), 1.0, Tween.TRANS_QUAD)
	_tween.start()


func _on_Tween_tween_all_completed()->void:
	if health <= 0:
		queue_free()
	_should_move = true


func _on_SlowZone_body_entered(body:PhysicsBody2D)->void:
	if body == target:
		target.adjacent_enemies += 1


func _on_SlowZone_body_exited(body:PhysicsBody2D)->void:
	if body == target:
		target.adjacent_enemies -= 1
