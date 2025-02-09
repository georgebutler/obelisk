extends Node

@export var world_resource: WorldSettings
@export var world_environment: WorldEnvironment
@export var chunk_scene: PackedScene
@export var player_scene: PackedScene

@onready var player_instance = player_scene.instantiate()
var loaded_chunks = {}

func _ready():
	world_environment.environment.fog_enabled = true
	world_environment.environment.fog_mode = Environment.FOG_MODE_DEPTH
	world_environment.environment.fog_depth_end = world_resource.render_distance * world_resource.chunk_size
	world_environment.environment.fog_depth_begin = 0
	
	player_instance.transform.origin = Vector3(0, 10, 0)
	add_child(player_instance)
	update_chunks(player_instance.transform.origin)

func _process(_delta):
	var player_position = player_instance.global_position
	update_chunks(player_position)

func update_chunks(player_position):
	# Get chunk size and render distance from world_resource
	var chunk_size = world_resource.chunk_size
	var render_distance = world_resource.render_distance
	
	# Calculate which chunks should be loaded based on the render distance
	var player_chunk_pos = Vector3(
		floor(player_position.x / chunk_size),
		0,
		floor(player_position.z / chunk_size)
	)
	
	# Keep track of chunks we want to keep
	var chunks_to_keep = {}
	
	# Load new chunks
	for x in range(int(player_chunk_pos.x) - render_distance, int(player_chunk_pos.x) + render_distance + 1):
		for z in range(int(player_chunk_pos.z) - render_distance, int(player_chunk_pos.z) + render_distance + 1):
			var chunk_key = Vector3(x, 0, z)
			chunks_to_keep[chunk_key] = true
			
			if not loaded_chunks.has(chunk_key):  # Changed from 'in' to 'has'
				var new_chunk = chunk_scene.instantiate()
				add_child(new_chunk)
				# Position chunk in the correct place
				new_chunk.position = Vector3(x * chunk_size, 0, z * chunk_size)  # Removed division by 2
				new_chunk.generate_chunk()
				loaded_chunks[chunk_key] = new_chunk
	
	# Unload chunks that are no longer needed
	var chunks_to_remove = []
	for chunk_key in loaded_chunks.keys():  # Explicitly get keys
		if not chunks_to_keep.has(chunk_key):
			chunks_to_remove.append(chunk_key)
	
	# Remove the chunks outside render distance
	for chunk_key in chunks_to_remove:
		if loaded_chunks.has(chunk_key):  # Safety check
			loaded_chunks[chunk_key].queue_free()
			loaded_chunks.erase(chunk_key)
