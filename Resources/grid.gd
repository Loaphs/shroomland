
class_name Grid
extends Resource


@export var size := Vector2(9, 9)
@export var cell_size := Vector2(2, 2)

var grid_array : Array[Vector2] 
var cell_num

func _ready():
	cell_num = size.x * size.y
	for cell_x in size.x:
		for cell_y in size.y:
			grid_array.append(Vector2(cell_x, cell_y))
