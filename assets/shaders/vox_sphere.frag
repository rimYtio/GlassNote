#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float u_time;
uniform vec2 u_size;
uniform float u_amplitude;
uniform float u_activation;
uniform float u_speechPulse;
uniform float u_status;
uniform float u_brightness;

out vec4 fragColor;

const float kGlassAlphaBase = 0.38;
const float kGlassAlphaFresnel = 0.14;
const float kVolumeBlueCeiling = 0.28;
const float kVioletReflectionMax = 0.18;

float saturate(float value) {
  return clamp(value, 0.0, 1.0);
}

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(
    mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
    mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
    u.y
  );
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / u_size;
  vec2 p = (fragCoord - u_size * 0.5) / min(u_size.x, u_size.y);
  p.y -= 0.018;

  float amplitude = saturate(u_amplitude);
  float activation = saturate(u_activation);
  float speechPulse = saturate(u_speechPulse);
  float time = u_time;
  float angle = atan(p.y, p.x);
  float radius = length(p);
  float energy = saturate(amplitude * 0.62 + activation * 0.46 + speechPulse * 0.24);

  float idleBreath = 0.007 * sin(time * 0.42 + angle * 2.0);
  float lowMode = sin(angle * 4.0 + time * 1.18) * (0.007 + amplitude * 0.018);
  float highMode = sin(angle * 7.0 - time * 1.55) * amplitude * 0.011;
  float gravity = smoothstep(-0.12, 0.42, p.y) * 0.026;
  float shapeRadius = 0.350 + idleBreath + lowMode + highMode + gravity + activation * 0.014;
  float signedDistance = radius - shapeRadius;
  float bodyMask = smoothstep(0.020, -0.018, signedDistance);
  float inner = saturate(1.0 - radius / max(shapeRadius, 0.001));

  if (bodyMask <= 0.001) {
    fragColor = vec4(0.0);
    return;
  }

  float edge = exp(-abs(signedDistance) * 38.0);
  float fresnel = pow(saturate(radius / max(shapeRadius, 0.001)), 4.4);
  float bodyNoise = noise(p * 7.5 + vec2(time * 0.045, -time * 0.035));
  float refractVeil = sin((p.x * 2.2 - p.y * 1.7) + bodyNoise * 3.4 + time * (0.32 + amplitude * 0.70));
  refractVeil = smoothstep(0.08, 1.0, refractVeil) * (0.050 + energy * 0.090);

  vec3 deep = vec3(0.030, 0.050, 0.082);
  vec3 volume = vec3(0.125, 0.205, kVolumeBlueCeiling);
  vec3 milky = vec3(0.640, 0.820, 0.900);
  vec3 cyan = vec3(0.180, 0.760, 0.920);
  vec3 violet = vec3(0.470, 0.360, 0.780);
  vec3 red = vec3(0.930, 0.300, 0.340);
  vec3 success = vec3(0.250, 0.820, 0.620);

  vec3 statusTint = cyan;
  statusTint = mix(statusTint, violet, smoothstep(1.6, 2.5, u_status));
  statusTint = mix(statusTint, success, smoothstep(3.5, 4.2, u_status) * (1.0 - smoothstep(4.6, 5.0, u_status)));
  statusTint = mix(statusTint, red, smoothstep(4.6, 5.0, u_status));

  vec3 color = mix(deep, volume, pow(inner, 0.52));
  color = mix(color, milky, smoothstep(0.18, 0.86, inner) * 0.22);
  color += statusTint * (edge * (0.18 + energy * 0.22));
  color += cyan * refractVeil;

  float core = exp(-dot(p, p) * (28.0 - energy * 7.0)) * (0.10 + energy * 0.62);
  float activationRing = exp(-abs(radius - mix(0.035, 0.335, activation)) * 58.0) * (1.0 - activation) * activation;
  float listeningRing = exp(-abs(radius - (0.13 + fract(time * (0.18 + amplitude * 0.22)) * 0.23)) * 48.0);
  listeningRing *= (0.035 + amplitude * 0.16);
  color += vec3(0.82, 0.94, 1.0) * core;
  color += cyan * activationRing * 0.80;
  color += violet * listeningRing * 0.24;

  float topGlint = exp(-length((p - vec2(-0.142, -0.195)) * vec2(1.0, 2.25)) * 12.5);
  float rightReflection = exp(-length((p - vec2(0.215, -0.020)) * vec2(2.5, 0.85)) * 6.4);
  float lowerRefraction = exp(-length((p - vec2(-0.020, 0.235)) * vec2(1.4, 2.3)) * 8.0);
  float sideGlint = exp(-abs(signedDistance + 0.008) * 82.0) *
      smoothstep(0.10, 0.62, sin(angle + time * (0.64 + amplitude * 0.72)) * 0.5 + 0.5);
  color += vec3(1.0, 1.0, 1.0) * topGlint * (0.28 + energy * 0.13);
  color += cyan * rightReflection * (0.050 + energy * 0.035);
  color += violet * lowerRefraction * kVioletReflectionMax;
  color += violet * sideGlint * (0.070 + energy * 0.080);

  float innerShadow = smoothstep(0.58, 0.96, uv.y) * smoothstep(-0.04, 0.36, p.y);
  color = mix(color, deep, innerShadow * 0.16);

  float lightCompensation = mix(1.0, 1.05, saturate(u_brightness));
  color *= lightCompensation;
  float alpha = bodyMask * (kGlassAlphaBase + fresnel * kGlassAlphaFresnel + core * 0.050);

  fragColor = vec4(color, alpha);
}
