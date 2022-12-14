class_name Player
extends KinematicBody2D

signal attack(heavy_attack)
signal update_speed(new_speed)

enum AttackKey {SPENT, PRIMARY, HEAVY, RANGED}

const PRIMARY_HIT_RADIUS := 15.0
const HEAVY_HIT_RADIUS := 25.0
const PRIMARY_DAMAGE := 2
const HEAVY_DAMAGE := 3
const RELOAD_TIME := 1.0
const SPEED_PENALTY_PER_ENEMY := 40

var _speed := 200.0
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
onready var _attack_sound = $AttackSound as AudioStreamPlayer


func _physics_process(delta:float)->void:
	if _game_over:
		return
	
	var movement_direction := Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()
	
	if _speed > 10 and not _animation_player.is_playing():
		_speed -= adjacent_enemies * delta * 2.0
		emit_signal("update_speed", _speed)
	
	# warning-ignore:return_value_discarded
	move_and_collide(_speed * movement_direction * delta)
	
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
		_attack_sound.volume_db = 0
		_attack_sound.pitch_scale = lerp(0.6, 1.1, randf())
		_attack_sound.play()
		emit_signal("attack", false)
		_animation_player.play("Primary")
		var index := _primary_attacks.find(AttackKey.PRIMARY)
		_primary_attacks.remove(index)
		
		_hit_area_collision_shape.shape.radius = _primary_hit_radius
		# the yield is necessary because otherwise the shape's radius is not resized
		# when the attack resolvesw
		yield(get_tree().create_timer(0.06), "timeout")
		
		for body in _hit_area.get_overlapping_bodies():
			if body.has_method("hit"):
				body.hit(PRIMARY_DAMAGE)


func _execute_heavy_attack()->void:
	if _heavy_attacks.has(AttackKey.HEAVY):
		_attack_sound.volume_db += 1 + 5 * randf()
		_attack_sound.pitch_scale = lerp(0.5, 1.0, randf())
		_attack_sound.play()
		emit_signal("attack", true)
		_animation_player.play("Heavy")
		var index := _heavy_attacks.find(AttackKey.HEAVY)
		_heavy_attacks.remove(index)
		
		if _speed <= 150.0:
			_speed += 5 * (1 + (1 - (_speed / 200)))
			emit_signal("update_speed", _speed)
		
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
	for i in 3:
		_primary_attacks.append(AttackKey.PRIMARY)
	_heavy_attacks.append(AttackKey.HEAVY)


func _on_CooldownTimer_timeout()->void:
	_can_attack = true


func _on_Main_game_over(victory:bool)->void:
	_game_over = true
	if not victory:
		pass
