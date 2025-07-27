extends Camera3D


@onready var player = $"../Character"

@export var offset = 10 


func _ready():
	make_current()

func _process(_delta):
	position.x = player.position.x
	position.z = player.position.z + offset
	
