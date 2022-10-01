extends %BASE%
# class description (one line)
# extended class description

# signals

# enums

# constants

# exported variables

# public variables

# private variables
var _color := Color.white
var _ignore

# onready variables
onready var collision := $CollisionShape2D

# METHOD ORDER:
# 1. built-in methods, starting with _init and _ready in that order
# 2. public methods
# 3. private methods

func _ready()->void%VOID_RETURN%:
	pass


func _process(delta:float)->void%VOID_RETURN%:
	pass


func _draw()->void:
	if collision != null:
		var shape = collision.get_shape()
		if shape is CircleShape2D:
			var radius = shape.radius
			draw_circle(-Vector2(radius,radius), radius, _color)
		elif shape is RectangleShape2D:
			var extents : Vector2 = shape.extents
			draw_rect(Rect2(-extents, extents*2), _color)
		elif shape is CapsuleShape2D:
		var radius = shape.radius
		var height = shape.height
		if collision.rotation_degrees != 270 and collision.rotation_degrees != 90:
			draw_circle(Vector2(0,height/2), radius, _color)
			draw_circle(-Vector2(0,height/2), radius, _color)
			draw_rect(Rect2(-Vector2(radius*2, height)/2, Vector2(radius*2, height)), _color)
		else:
			 draw_circle(Vector2(height/2,0), radius, _color)
			 draw_circle(-Vector2(height/2,0), radius, _color)
			 draw_rect(Rect2(-Vector2(height, radius*2)/2, Vector2(height, radius*2)), _color)
