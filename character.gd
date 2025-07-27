extends Sprite3D




#THIS WILL BE HANDLED IN RESOURCES (OR WHATEVER CARD SYSTEM WE USE)



"""
@export var speed = 30
func _process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	
	position.x += direction * speed * delta
"""
@export var move_frames : int
@export var move_queue : PackedVector2Array
@export var moving : bool

var current_grid_position: Vector2


func _ready():
	position = Vector3(1, 3, 0)
