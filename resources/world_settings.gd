extends Resource
class_name WorldSettings

@export var chunk_size: int = 16
@export var resolution: int = 16
@export var noise_scale: float = 1.0
@export var height_scale: float = 5.0
@export var render_distance: int = 3
@export var noise: FastNoiseLite
