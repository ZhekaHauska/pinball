extends Spatial
class_name RGBCameraSensor3D

func get_camera_pixel_encoding():
	var im =  $Viewport.get_texture().get_data()
	im.flip_y()
	return im.data["data"].hex_encode()

func get_camera_shape()-> Array:
	return [$Viewport.size[1], $Viewport.size[0], 4]
