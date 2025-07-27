extends Node3D


@export var size := Vector2(5, 5)
@export var cell_size := Vector2(2, 2)

@export var move_speed := .2

var grid_array : Array[Vector2] 
var used_cells : Array[Vector3i]
var available_cells : Array[Vector3i]
var cell_num : int
var cell : Vector2
var grid_center := Vector2(floori(size.x/2), floori(size.y/2))
var moving : bool

var grid : GridMap
var player : Node3D

var current_path : Array[Vector2]   #add each following cell to the path

# for cell in current_path: set_cell(cell, 0)

func _ready():
	cell_num = size.x * size.y
	for cell_y in size.y:
		for cell_x in size.x:
			grid_array.append(Vector2(cell_x, cell_y))
	print(grid_array)
	cell = grid_center
	grid = $"../GridMap"
	player = $"../Character"
	
	
func sort_array(a: Vector3i, b: Vector3i) -> bool:
	if a.z == b.z:
		return a.x < b.x
	else:
		return a.z > b.z

	
func move():
	moving = true
	used_cells = grid.get_used_cells()
	
	var player_pos = grid.map_to_local(player.position)
	var x_range = [player_pos.x - size.x/2, player_pos.x + size.x/2]
	var y_range = [player_pos.z - size.y/2, player_pos.z + size.y/2]
	print('\n', x_range, '\n', y_range)
	used_cells = used_cells.filter(func(coordinates): return coordinates.x >= x_range[0] && coordinates.x <= x_range[1] && coordinates.z >= y_range[0] && coordinates.z <= y_range[1] && coordinates.y == 0)
	used_cells.sort_custom(sort_array)
	print("\n")
	print(used_cells)
	print("\n")
	print(used_cells.size())
	
	
	
	
	"""
	for x in size.x:
		for y in size.y:
			var current_index = grid_array.find(Vector2(x, y))
			var cell_on_index
			available_cells.get(current_index) = 
		
			#get the range of items in array within the range of the coordinate size into an array.  SPECIFY THE Y, THE LAYER OF GRIDMAP ITEMS
			#OH BUT UNRELATED, ADD THIRD FIGHT CAMERA
		"""
	
	
	#REWRITE FOLLOW PATH SO THAT IT TAKES THE CELL TO THE RIGHT, RATHER THAN GRID INDEX 
	
func follow_path() -> void:
	print(grid_array)
	print(current_path)
	for square in current_path:
		var current_index = grid_array.find(square)
		print(current_index)
		player.position.x = grid.local_to_map(used_cells[current_index]).x
		player.position.z = grid.local_to_map(used_cells[current_index]).z
		await get_tree().create_timer(move_speed).timeout
		
	if self.cell == current_path.back():
		moving = false
		clear_path()
			
func clear_path():
	for node in grid.get_used_cells_by_item(6):
		grid.set_cell_item(node, -1)
	current_path.clear()
	print('\n', grid.map_to_local(player.position) + Vector3.DOWN, '\n', used_cells.find(Vector3i((grid.map_to_local(player.position))) + Vector3i.DOWN))


func _unhandled_input(event: InputEvent):
	if moving:
		var arrow_pressed = false
		var previous_cell = current_path.back()
		var path_cell = Vector3i.ZERO
		var last_action = Vector3i.ZERO
		if event.is_action_pressed("ui_right"):
			arrow_pressed = true
			path_cell += Vector3i.RIGHT
			last_action = Vector3i.RIGHT
		elif event.is_action_pressed("ui_up"):
			arrow_pressed = true
			path_cell += Vector3i.FORWARD
			last_action = Vector3i.FORWARD
		elif event.is_action_pressed("ui_left"):
			arrow_pressed = true
			path_cell += Vector3i.LEFT
			last_action = Vector3i.LEFT
		elif event.is_action_pressed("ui_down"):
			arrow_pressed = true
			path_cell += Vector3i.BACK
			last_action = Vector3i.UP
		elif event.is_action_pressed("ui_accept"):
			follow_path()
		elif event.is_action_pressed("ui_menu"):
			clear_path()
		
		if arrow_pressed:
			current_path.append(path_cell)
		
		
			var cell_index = grid_array.find(self.cell)
		
			if previous_cell:
				if previous_cell == path_cell:
					grid.set_cell_item(used_cells[cell_index] + Vector3i.UP, -1)
					current_path.remove_at(-1)
			else:
				print("\n", path_cell, '\n')
				var local_position = grid.map_to_local(player.position)
				var cell_holder = Vector3i(local_position.x, 1, local_position.y) + path_cell
				print(cell_holder)
				grid.set_cell_item(cell_holder, 6)
			
			"""
			if cell not in grid_array:
				cell -= last_action
			if previous_cell == self.cell:
				grid.set_cell_item(used_cells[cell_index] + Vector3i.UP, -1)
				var garbage = current_path.pop_back()
			else:
				grid.set_cell_item(used_cells[cell_index] + Vector3i.UP, 6)"""
			
	else:
		if event.is_action_pressed("space"):   
			move()
			moving = true
	
	
	
	#OKAY THIS IS HOW ITS GONNA WORK
	# so, we use get_used_cells() to get an array of coordinates, then we find the xy cell that our character resides in. We use cell size and the coordinates to center the character
	# so current active cell is the one where we sit. then, upon pressing an arrow key, it temporarily selects a cell next to the character, set_cell_item(index) into a white rect
	# after that, the cell is added to current_path, which we will then use upon an action to move
	
	#match index between both arrays.
