
uniform sampler2D tex0;
varying vec2 tcoord;
varying vec4 color;

uniform vec2 resolution;
uniform float time;

const float bloom = 0.25;  // TODO make uniform input (bloom = good / points)
const float vignetteAmount = 25.0;

void main()
{
    vec2 q = gl_FragCoord.xy / resolution.xy;
    vec2 uv = 0.5 + (q - 0.5);
    // vec2 uv = 0.5 + (q - 0.5) * (0.9 + 0.1 * sin(0.2 * uTime));
    vec3 col;
    vec4 sum = vec4(0);
    vec4 curcol = texture2D(tex0, tcoord);

    // neighbourhood interpolation for bloom
    for(int i = -3; i <= 3; i += 1) {
        for (int j = -3; j <= 3; j += 1) {
            sum += texture2D(tex0, tcoord + vec2(j,i) * 0.004) * 0.13;
        }
    }
          
    col = curcol.rgb;

    // col = clamp(col*0.5+0.5*col*col*1.2,0.0,1.0);          // tone curve
    col *= 0.8 + 0.2 * vignetteAmount * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y); // vignette
    // col *= vec3(0.7,1.0,0.6);                              // green tint

    // bloom
    gl_FragColor = bloom * (sum * sum) * (1.0 - curcol.r) / 40.0 + vec4(col, 1.0);
}
