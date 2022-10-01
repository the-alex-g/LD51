class_name Player
extends KinematicBody2D

enum AttackKey {SPENT, PRIMARY, HEAVY, RANGED}

const SPEED := 200
const PRIMARY_HIT_RADIUS := 15.0
const HEAVY_HIT_RADIUS := 25.0
const PRIMARY_DAMAGE := 2
const HEAVY_DAMAGE := 3
const RELOAD_TIME := 1.0
const SPEED_PENALTY_PER_ENEMY := 30

var _primary_attacks := [AttackKey.PRIMARY, AttackKey.PRIMARY, AttackKey.PRIMARY]
var _heavy_attacks := [AttackKey.HEAVY]
var _can_attack := true
var _game_over := false
var adjacent_enemies := 0

onready var _body_radius = $CollisionShape2D.shape.radius as float
onready var _primary_hit_radius = _body_radius + PRIMARY_HIT_RADIUS as float
onready var _heavy_hit_radius = _body_radius + HEAVY_HIT_RADIUS as float
onready var _hit_area = $HitArea as Area2D
onready var _hit_area_collision_shape = $HitArea/CollisionShape2D as CollisionShape2D
onready var _cooldown_timer = $CooldownTimer as Timer
onready var _sprite = $Sprite as AnimatedSprite
onready var _animation_player = $Attack as AnimationPlayer


func _physics_process(delta:float)->void:
	if _game_over:
		return
	
	var movement_direction := Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()
	
	var speed := max(10, SPEED - (SPEED_PENALTY_PER_ENEMY * adjacent_enemies))
	
	# warning-ignore:return_value_discarded
	move_and_collide(speed * movement_direction * delta)
	
	if _can_attack:
		if Input.is_action_just_pressed("primary_attack"):
			_attack(AttackKey.PRIMARY)
		if Input.is_action_just_pressed("heavy_attack"):
			_attack(AttackKey.HEAVY)
	
	if abs(movement_direction.x) > abs(movement_direction.y):
		_sprite.play("Horizontal")
	else:
		_sprite.play("Vertical")


func _attack(type:int)->void:
	_can_attack = false
	_cooldown_timer.start(RELOAD_TIME)
	match type:
		AttackKey.PRIMARY:
			_execute_primary_attack()
		AttackKey.HEAVY:
			_execute_heavy_attack()


func _execute_primary_attack()->void:
	if _primary_attacks.has(AttackKey.PRIMARY):
		_animation_player.play("Primary")
		var index := _primary_attacks.find(AttackKey.PRIMARY)
		_primary_attacks[index] = AttackKey.SPENT
		
		_hit_area_collision_shape.shape.radius = _primary_hit_radius
		# the yield is necessary because otherwise the shape's radius is not resized
		# when the attack resolvesw
		yield(get_tree().create_timer(0.06), "timeout")
		
		for body in _hit_area.get_overlapping_bodies():
			if body.has_method("hit"):
				body.hit(PRIMARY_DAMAGE)


func _execute_heavy_attack()->void:
	if _heavy_attacks.has(AttackKey.HEAVY):
		_animation_player.play("Heavy")
		var index := _heavy_attacks.find(AttackKey.HEAVY)
		_heavy_attacks[index] = AttackKey.SPENT
		
		_hit_area_collision_shape.shape.radius = _heavy_hit_radius
		# the yield is necessary because otherwise the shape's radius is not resized
		# when the attack resolves
		yield(get_tree().create_timer(0.06), "timeout")
		
		for body in _hit_area.get_overlapping_bodies():
			if body.has_method("hit"):
				body.hit(HEAVY_DAMAGE)


func _on_Main_ten_second_mark()->void:
	_reset_attacks()


func _reset_attacks()->void:
	for i in _primary_attacks.size():
		_primary_attacks[i] = AttackKey.PRIMARY
	for i in _heavy_attacks.size():
		_heavy_attacks[i] = AttackKey.HEAVY


func _on_CooldownTimer_timeout()->void:
	_can_attack = true


func _on_Main_game_over(victory:bool)->void:
	_game_over = true
	if not victory:
		pass
