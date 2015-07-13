
#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;
varying vec2 tcoord;
varying vec4 color;

uniform vec2 resolution;
uniform float time;

// Bloom:
const int samples = 5; // pixels per axis; higher = bigger glow, worse performance
const float quality = 2.5; // lower = smaller glow, better quality

const float bloomAmount = 0.20;  // TODO make uniform input (bloom = good / points)
const float vignetteAmount = 30.0;

void main()
{
    vec2 q = gl_FragCoord.xy / resolution.xy;
    vec2 uv = 0.5 + (q - 0.5);
    vec4 source = texture2D(tex0, tcoord);

    vec4 sum = vec4(0);
    const int diff = (samples - 1) / 2;
    vec2 sizeFactor = vec2(1) / resolution.xy * quality;

    for (int x = -diff; x <= diff; x++) {
        for (int y = -diff; y <= diff; y++) {
            vec2 offset = vec2(x, y) * sizeFactor;
            sum += texture2D(tex0, tcoord + offset);
        }
    }
  
    gl_FragColor = ((sum / float(samples * samples)) * bloomAmount + source);
    gl_FragColor *= 0.8 + 0.2 * vignetteAmount * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y); // vignette
}
