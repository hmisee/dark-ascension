extends ColorRect
class_name ScrollingBackground

## Infinite tiling background that follows the camera.
## Attach the dungeon_floor_bg shader material to this node.

var _material: ShaderMaterial

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_material = material as ShaderMaterial

func _process(_delta: float) -> void:
	if not _material:
		return
	var cam := get_viewport().get_camera_2d()
	if cam:
		_material.set_shader_parameter("camera_offset", cam.global_position)
