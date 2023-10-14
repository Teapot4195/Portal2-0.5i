shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,unshaded;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_linear_mipmap,repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;
uniform float specular;
uniform float metallic;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;


void vertex() {
	//UV=UV*uv1_scale.xy+uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;
	//vec4 albedo_tex = vec4(UV, 0.5, 1.0)*abs(sin(TIME)); // testing
	vec4 albedo_tex;
	if (UV.x < 0.01 || UV.x > 0.99 || UV.y < 0.01 || UV.y > 0.99) // make a border around the portal so it's easier to see
		albedo_tex = vec4(0,0,0,1);
	else albedo_tex = texture(texture_albedo,UV);
	ALBEDO = albedo_tex.rgb;
	
}




