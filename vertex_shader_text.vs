#version 330 core

layout(location = 0) in vec2 vertexPosition;
layout(location = 1) in vec4 instanceGlyph;


uniform sampler2D sampler_font;
uniform sampler2D sampler_meta;

uniform float offset_firstline; // ascent - descent - linegap/2
uniform float scale_factor;     // scaling factor proportional to font size

uniform vec2 string_offset;     // offset of upper-left corner

uniform vec2 res_meta;   // 96x2 
uniform vec2 res_bitmap; // 512x256
uniform vec2 resolution;    // screen resolution

out vec2 uv;
out float color_index; // for syntax highlighting

void main(){
    vec2 res_meta = textureSize(sampler_meta, 0);    
    vec2 res_bitmap = textureSize(sampler_font, 0);  

    // (xoff, yoff, xoff2, yoff2)
    vec4 q2 = texture(sampler_meta, vec2((instanceGlyph.z + 0.5)/res_meta.x, 0.75))*vec4(res_bitmap, res_bitmap);
    
    vec2 p;
    p = vec2(1.0, -1.0)*(vertexPosition*(q2.zw - q2.xy) + q2.xy);
    p.y -= offset_firstline;
    p *= scale_factor;
    p += instanceGlyph.xy + string_offset;
    p *= 2.0/resolution;
    p += vec2(-1.0, 1.0);
    
    // send the correct uv's in the font atlas to the fragment shader
    // (x0, y0, x1-x0, y1-y0)
    vec4 q = texture(sampler_meta, vec2((instanceGlyph.z + 0.5)/res_meta.x, 0.25));
    uv = q.xy + vertexPosition*q.zw;
    color_index = instanceGlyph.w;

    gl_Position = vec4(p, 0.0, 1.0);
}

