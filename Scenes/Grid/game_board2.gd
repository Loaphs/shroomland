extends Node3D


@export var size := Vector2(13, 13) 	# HAS TO BE ODD (doesn't have to be, but please make odd)
@export var cell_size := Vector2(2, 2)

@export var move_speed := .2

var grid_array : PackedVector2Array
var selected_grid : PackedVector2Array
var creature_grid : PackedVector2Array
var used_cells : Array[Vector3i]
var grid_center := Vector2(floori(size.x/2), floori(size.y/2))
var grid_world_center : Vector3i
var cell : Vector2
var total_movement : Vector2


var grid : GridMap
var player : Node3D

var selected_creature
@export var creatures : Array[Node3D]


func _ready():
	grid = $"../GridMap"
	player = $"../Character"
	player.moving = false
	used_cells = grid.get_used_cells()
	enter_combat()
	creatures.append(player)
	
	
# DECLARES GLOBAL COMBAT
func enter_combat():
	GlobalVariables.combat = true
	create_grid()

# CREATES GRID
func create_grid():
	# CREATES GRID ARRAY, (9,9), STARTING AT (-4) AND GOING TO (4) (or whatever the size is)
	for y in size.y:
		for x in size.x:
			grid_array.append(Vector2(x, y) - grid_center)
			
	# SETS THE PLAYER POSITION IN THE GRID TO 0,0, THE CENTER OF THE GRID 
	player.current_grid_position = Vector2.ZERO
	grid_world_center = to_global(grid.map_to_local(player.position))
	for creature in creatures:
		creature_grid.append(Vector2(grid.map_to_local(creature.position).x + grid_world_center.x, grid.map_to_local(creature.position).z + grid_world_center.z))


# ADDS MOVEMENT ORDER TO QUEUE
func add_move_item(item):
	# CHECKS BOUND ON MOVEMENT ORDERS ACCORDING TO CREATURE TYPE
	if selected_creature.move_queue.size() <= selected_creature.move_frames - 1:
			# CHECKS BOUND ON MOVEMENT ORDERS ACCORDING TO GRID SIZE AND LEVEL DESIGN 
			total_movement += item
			var final_position = total_movement + selected_creature.current_grid_position
			var final_cell = Vector3i(final_position.x, 0, final_position.y)
			if used_cells.has(final_cell):
				print(creature_grid)
				if used_cells.has(final_cell + Vector3i.UP) or creature_grid.has(final_position):
					print('obstacle in the way')
					total_movement -= item
				else:
					if grid_array.has(final_position):
						selected_creature.move_queue.append(item) # ADDS MOVEMENT ITEM (VECTOR2.[DIRECTION])
						if !selected_grid.is_empty():
							selected_grid.append(selected_grid[selected_grid.size() - 1] + item)
						else:
							selected_grid.append(selected_creature.current_grid_position + item)
						
						# CREATES TEMPORARY VECTOR3 WHERE "CURSOR" IS, HIGHLIGHTING EACH SELECTED GRIDMAP ITEM
						var temp_cell = Vector3i(selected_grid[selected_grid.size() - 1].x, 1, selected_grid[selected_grid.size() - 1].y)
						grid.set_cell_item(temp_cell, 6)
					else:
						print('out of grid range')
						total_movement -= item
			else:
				print('out of boundary')
				total_movement -= item
	else:
		print('out of move frames')

# ALLOW MOVE ORDERS
func set_move(creature):
	selected_creature = creature
	if !selected_creature.moving: # INITIATE MOVEMENT SEQUENCE
		print('start')
		selected_creature.moving = true
	else:
		print('already moving')
		
# INITIATE MOVE SEQUENCE
func move():
	var last_position = selected_creature.current_grid_position
	for item in selected_creature.move_queue: # FOLLOW MOVEMENT QUEUE
		selected_creature.position.x += item.x * cell_size.x
		selected_creature.position.z += item.y * cell_size.y
		selected_creature.current_grid_position += item # ADDS EACH ITEM TO CURRENT GRID POSITION
		print('moving')
		
		#CLEAR "SELECTED" TILES
		if !selected_grid.is_empty():
			grid.set_cell_item(Vector3i(selected_grid[0].x, 1, selected_grid[0].y), -1)
			selected_grid.remove_at(0)
		
		await get_tree().create_timer(move_speed).timeout # CHANGES MOVE SPEED
	
	# RESET ARRAYS
	print('clear')
	selected_grid.clear()
	selected_creature.move_queue.clear()
	total_movement = Vector2.ZERO
	
	
	print(creature_grid)
	print(last_position)
	creature_grid.remove_at(creature_grid.find(last_position))
	creature_grid.append(selected_creature.current_grid_position)
	print(creature_grid)
	
	# END MOVE SEQUENCE
	selected_creature.moving = false
	
# HANDLES ALL INPUT (DUE TO TURN BASED, NO NEED FOR _process() (FRAME UPDATES)
func _unhandled_input(event):
	if event.is_action_pressed("space"): # INITIATE MOVE SEQUENCE
		set_move(player)
	if event.is_action_pressed("ui_accept") and selected_creature:
		move()
	
	if selected_creature != null:
		if selected_creature.moving: # ADD MOVE ORDER TO QUEUE
			if event.is_action_pressed("ui_up"):
				add_move_item(Vector2.UP)
			elif event.is_action_pressed("ui_down"):
				add_move_item(Vector2.DOWN)
			elif event.is_action_pressed("ui_right"):
				add_move_item(Vector2.RIGHT)
			elif event.is_action_pressed("ui_left"):
				add_move_item(Vector2.LEFT)
			
			# CLEAR CURRENT QUEUE
			if event.is_action_pressed("ui_menu"):
				for item in selected_grid.size():
					grid.set_cell_item(Vector3i(selected_grid[item].x, 1, selected_grid[item].y), -1)
				
				selected_grid.clear()
				selected_creature.move_queue.clear()
