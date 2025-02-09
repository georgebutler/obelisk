@tool
extends StaticBody3D

@export var world_resource: WorldSettings
@export var chunk_material: Material

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready():
	if not Engine.is_editor_hint():
		generate_chunk()

func generate_chunk():
	if not world_resource or not world_resource.noise:
		return

	var chunk_size = world_resource.chunk_size
	var resolution = world_resource.resolution
	var noise = world_resource.noise

	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	var colors = PackedColorArray()

	# Calculate the actual world position of this chunk's origin
	var chunk_world_x = global_position.x # Multiply by 2 to account for the division in world.gd
	var chunk_world_z = global_position.z

	# Generate vertices and colors
	for x in range(resolution + 1):
		for z in range(resolution + 1):
			# Calculate the actual world coordinates for noise sampling
			var world_x = chunk_world_x + (x * chunk_size / resolution)
			var world_z = chunk_world_z + (z * chunk_size / resolution)
			
			# Apply noise scale from world settings
			var scaled_x = world_x * world_resource.noise_scale
			var scaled_z = world_z * world_resource.noise_scale
			
			# Get height and apply height scale
			var height = noise.get_noise_2d(scaled_x, scaled_z) * world_resource.height_scale

			# Calculate local vertex position within the chunk
			var vertex_x = (x * chunk_size / resolution)
			var vertex_z = (z * chunk_size / resolution)
			var vertex = Vector3(vertex_x, height, vertex_z)
			vertices.append(vertex)

			# Height-based color
			var color_value = (height / world_resource.height_scale + 1) / 2  # Normalize to 0-1 range
			colors.append(Color(color_value, color_value, color_value))

	# Generate indices for triangles
	for x in range(resolution):
		for z in range(resolution):
			var i = x * (resolution + 1) + z
			indices.append(i)
			indices.append(i + resolution + 1)
			indices.append(i + 1)
			indices.append(i + 1)
			indices.append(i + resolution + 1)
			indices.append(i + resolution + 2)

	# Create ArrayMesh
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices

	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	# Assign mesh and material
	mesh_instance.mesh = arr_mesh
	if chunk_material:
		mesh_instance.material_override = chunk_material

	# Update physics collision
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(arr_mesh.get_faces())
	collision_shape.shape = shape
