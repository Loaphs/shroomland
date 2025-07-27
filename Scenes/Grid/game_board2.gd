extends Node3D


@export var size := Vector2(9, 9)
@export var cell_size := Vector2(2, 2)

@export var move_speed := .2

var grid_array : PackedVector2Array
var selected_grid : PackedVector2Array
var grid_center := Vector2(floori(size.x/2), floori(size.y/2))
var grid_world_center : Vector3i
var cell : Vector2


var grid : GridMap
var player : Node3D

var selected_creature


func _ready():
	grid = $"../GridMap"
	player = $"../Character"
	player.moving = false
	enter_combat()


func enter_combat():
	GlobalVariables.combat = true
	create_grid()


func create_grid():
	for y in size.y:
		for x in size.x:
			grid_array.append(Vector2(x, y) - grid_center)
	player.current_grid_position = Vector2.ZERO
	
	#PROBLEM WITH SETTING THE GRID_WORLD_CENTER (NOT CENTERED ON PLAYER, WEIRD INTERACTION WITH PLAYER COORDS)
	
	grid_world_center = to_global(grid.map_to_local(player.position)) + Vector3(-3, 0, -1)
	grid.set_cell_item(Vector3(grid_world_center.x, 0, grid_world_center.z), 6)

func add_move_item(item):
	if selected_creature.move_queue.size() >= selected_creature.move_frames:
		selected_creature.move_queue.append(item)
		if !selected_grid.is_empty():
			selected_grid.append(selected_grid[selected_grid.size() - 1] + item)
		else:
			selected_grid.append(selected_creature.current_grid_position + item)
		var temp_cell = Vector3i(selected_grid[selected_grid.size() - 1].x + grid_world_center.x, 1, selected_grid[selected_grid.size() - 1].y + grid_world_center.z)
		grid.set_cell_item(temp_cell, 6)
	else:
		pass

func move(creature):
	selected_creature = creature
	if !selected_creature.moving:
		print('start')
		selected_creature.moving = true
	else:
		for item in selected_creature.move_queue:
			selected_creature.position.x += item.x * cell_size.x
			selected_creature.position.z += item.y * cell_size.y
			selected_creature.current_grid_position += item
			print('moving')
			await get_tree().create_timer(move_speed).timeout
		
		print(selected_grid)
		
		for item in selected_grid:
			var temp_cell = Vector3i(selected_grid[selected_grid.size() - 1].x + grid_world_center.x, 1, selected_grid[selected_grid.size() - 1].y + grid_world_center.z)
			grid.set_cell_item(temp_cell, -1)
		
		selected_grid.clear()
		selected_creature.move_queue.clear()
		
		print(selected_creature.current_grid_position)
		
		selected_creature.moving = false
	
func _unhandled_input(event):
	if event.is_action_pressed("space"):
		move(player)
	
	if selected_creature != null:
		if selected_creature.moving:
			if event.is_action_pressed("ui_up"):
				add_move_item(Vector2.UP)
			elif event.is_action_pressed("ui_down"):
				add_move_item(Vector2.DOWN)
			elif event.is_action_pressed("ui_right"):
				add_move_item(Vector2.RIGHT)
			elif event.is_action_pressed("ui_left"):
				add_move_item(Vector2.LEFT)
			
			if event.is_action_pressed("ui_accept"):
				move(player)
