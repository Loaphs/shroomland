extends Node3D


@export var size := Vector2(9, 9)
@export var cell_size := Vector2(2, 2)

@export var move_speed := .2

var grid_array : PackedVector2Array
var selected_grid : PackedVector2Array
var grid_center := Vector2(floori(size.x/2), floori(size.y/2))
var grid_world_center : Vector3i
var cell : Vector2
var total_movement : Vector2


var grid : GridMap
var player : Node3D

var selected_creature


func _ready():
	grid = $"../GridMap"
	player = $"../Character"
	player.moving = false
	enter_combat()

# DECLARES GLOBAL COMBAT
func enter_combat():
	GlobalVariables.combat = true
	create_grid()

# CREATES GRID
func create_grid():
	# CREATES GRID ARRAY, (9,9), STARTING AT (-4) AND GOING TO (4)
	for y in size.y:
		for x in size.x:
			grid_array.append(Vector2(x, y) - grid_center)
	# SETS THE PLAYER POSITION IN THE GRID TO 0,0, THE CENTER OF THE GRID
	player.current_grid_position = Vector2.ZERO
	
	# ******* PROBLEM WITH SETTING THE GRID_WORLD_CENTER (NOT CENTERED ON PLAYER, WEIRD INTERACTION WITH PLAYER COORDS)
	
	# GETS THE GRID CENTER IN GLOBAL COORDINATES
	grid_world_center = to_global(grid.map_to_local(player.position))

# ADDS MOVEMENT ORDER TO QUEUE
func add_move_item(item):
	# CHECKS BOUND ON MOVEMENT ORDERS ACCORDING TO CREATURE TYPE
	if selected_creature.move_queue.size() <= selected_creature.move_frames - 1:
		# CHECKS BOUND ON MOVEMENT ORDERS ACCORDING TO GRID SIZE
		total_movement += item
		if grid_array.has(total_movement + selected_creature.current_grid_position):
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
		print('out of move frames')

# MOVE COMMAND, BOTH TO INITIATE MOVEMENT SEQUENCE AND FOLLOW MOVEMENT QUEUE
func move(creature):
	selected_creature = creature
	if !selected_creature.moving: # INITIATE MOVEMENT SEQUENCE
		print('start')
		selected_creature.moving = true
	else:
		for item in selected_creature.move_queue: # FOLLOW MOVEMENT QUEUE
			selected_creature.position.x += item.x * cell_size.x
			selected_creature.position.z += item.y * cell_size.y
			selected_creature.current_grid_position += item # ADDS EACH ITEM TO CURRENT GRID POSITION
			print('moving')
			
			#CLEAR "SELECTED" TILES
			grid.set_cell_item(Vector3i(selected_grid[0].x, 1, selected_grid[0].y), -1)
			selected_grid.remove_at(0)
			
			await get_tree().create_timer(move_speed).timeout # CHANGES MOVE SPEED
		
		# RESET ARRAYS
		print('clear')
		selected_grid.clear()
		selected_creature.move_queue.clear()
		total_movement = Vector2.ZERO
		
		print(selected_creature.current_grid_position)
		
		# END MOVE SEQUENCE
		selected_creature.moving = false
	
# HANDLES ALL INPUT (DUE TO TURN BASED, NO NEED FOR _process() (FRAME UPDATES)
func _unhandled_input(event):
	if event.is_action_pressed("space"): # INITIATE MOVE SEQUENCE
		move(player)
	
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
