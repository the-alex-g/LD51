class_name Enemy
extends KinematicBody2D

const KNOCKBACK_DISTANCE := Vector2(100, 0)

var target : Player
var _move_in_reverse := false
var _game_over := false

export var speed := 175
export var health := 6

onready var _knockback_timer = $KnockbackTimer as Timer
onready var _sprite = $AnimatedSprite as AnimatedSprite


func _physics_process(delta:float)->void:
	if _game_over:
		return
	
	if _can_see_target():
		var angle = get_angle_to(target.position)
		
		var movement_direction := Vector2.RIGHT.rotated(angle) * (-1 if _move_in_reverse else 1)
		
		# warning-ignore:return_value_discarded
		move_and_collide(movement_direction * speed * delta)
	
		if abs(movement_direction.x) > abs(movement_direction.y):
			_sprite.play("Horizontal")
			_sprite.flip_h = movement_direction.x < 0
		elif movement_direction.y < 0:
			_sprite.play("Up")
		else:
			_sprite.play("Down")


func _can_see_target()->bool:
	var intersection := get_world_2d().direct_space_state.intersect_ray(global_position, target.global_position, [self])
	if intersection.size() > 0:
		return intersection.collider == target
	else:
		return false


func hit(damage:int)->void:
	health -= damage
	_move_in_reverse = true
	_knockback_timer.start()


func _on_SlowZone_body_entered(body:PhysicsBody2D)->void:
	if body == target:
		target.adjacent_enemies += 1


func _on_SlowZone_body_exited(body:PhysicsBody2D)->void:
	if body == target:
		target.adjacent_enemies -= 1


func _on_KnockbackTimer_timeout()->void:
	_move_in_reverse = false
	if health <= 0:
		queue_free()


func _on_Main_game_over(_victory:bool)->void:
	_game_over = true
