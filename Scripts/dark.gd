extends ColorRect

var shader_time := 0.0

func _process(delta):
	shader_time += delta
	
	var shader_material = self.material as ShaderMaterial
	
	if shader_material:
		shader_material.set_shader_parameter("time", shader_time)
