Shader "Unlit/Reflect"
{
	Properties
	{
		_Step("Step", float) = 0.05
		_Steps("Steps", int) = 200
		_MaxDif("MaxDif", float) = 0.05
		_MN("Min", float) = 0.45
		_MX("Max", float) = 0.5
		_GP("GP Cut", float) = 0.45
		_RI("Rain Intensity", float) = 0.02
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent-1"}
		LOD 100

		Blend SrcAlpha OneMinusSrcAlpha
		GrabPass { "_GpRef" }
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 rvp : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			float _Step;
			int _Steps;
			float _MaxDif;
			sampler2D _GpRef;
			sampler2D_float _CameraDepthTexture;
			float _MN;
			float _MX;
			float _GP;
			float _RI;
			#define MAX_RADIUS 2

			#define DOUBLE_HASH 0

			#define HASHSCALE1 .1031
			#define HASHSCALE3 float3(.1031, .1030, .0973)

			float hash12(float2 p)
			{
				float3 p3  = frac(float3(p.xyx) * HASHSCALE1);
				p3 += dot(p3, p3.yzx + 19.19);
				return frac((p3.x + p3.y) * p3.z);
			}

			float2 hash22(float2 p)
			{
				float3 p3 = frac(float3(p.xyx) * HASHSCALE3);
				p3 += dot(p3, p3.yzx+19.19);
				return frac((p3.xx+p3.yz)*p3.zy);

			}
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.rvp = v.vertex;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float luv = length(i.uv-0.5);
				if(luv > _MX) {
					return fixed4(0,0,0,0);
				} else {
					float2 uv = mul(unity_ObjectToWorld, i.rvp).xz*4;//i.uv*50;
					float2 p0 = floor(uv);

					float2 circles = float2(0.,0.);
					for (int j = -MAX_RADIUS; j <= MAX_RADIUS; ++j)
					{
						for (int i = -MAX_RADIUS; i <= MAX_RADIUS; ++i)
						{
							float2 pi = p0 + float2(i, j);
							#if DOUBLE_HASH
							float2 hsh = hash22(pi);
							#else
							float2 hsh = pi;
							#endif
							float2 p = pi + hash22(hsh);

							float t = frac(0.3*_Time.y + hash12(hsh));
							float2 v = p - uv;
							float d = length(v) - (float(MAX_RADIUS) + 1.)*t;

							float h = 1e-3;
							float d1 = d - h;
							float d2 = d + h;
							float p1 = sin(31.*d1) * smoothstep(-0.6, -0.3, d1) * smoothstep(0., -0.3, d1);
							float p2 = sin(31.*d2) * smoothstep(-0.6, -0.3, d2) * smoothstep(0., -0.3, d2);
							circles += 0.5 * normalize(v) * ((p2 - p1) / (2. * h) * (1. - t) * (1. - t));
						}
					}
					circles /= float((MAX_RADIUS*2+1)*(MAX_RADIUS*2+1))*0.5;

					float3 n = float3(circles, sqrt(1. - dot(circles, circles)));
					i.rvp.xz -= _RI*n.xy;
					float3 wpos = mul(unity_ObjectToWorld, i.rvp).xyz;
					float3 wmov = normalize(wpos - _WorldSpaceCameraPos);
					wmov.y = -wmov.y;
					wmov*=_Step;//abs(wmov.y);
					float depth;
					float4 view;
					float4 gp;
					fixed4 col = fixed4(0,0,0,0);
					for(int j = 0; j < _Steps; j++) {
						wpos+=wmov;
						view = mul(UNITY_MATRIX_V, float4(wpos, 1));
						gp = ComputeGrabScreenPos(mul(UNITY_MATRIX_P, view));
						gp/=gp.w;
						if(gp.y < 0 || gp.y > 1 || gp.x < 0 || gp.x > 1) {
							break;
						}
						depth = Linear01Depth(DecodeFloatRG(tex2Dlod(_CameraDepthTexture, float4(gp.xy, 0, 0))));
						view*=float4(-1,-1,1,0);
						view*=depth*_ProjectionParams.z/view.z;
						view.w = 1;
						if(distance(wpos, mul(unity_CameraToWorld, view).xyz) <= _MaxDif) {
							col = tex2Dlod(_GpRef, float4(gp.xy, 0, 0));
							col.a = (_Steps-j)*1.0/_Steps;
							if(abs(gp.x-0.5) > _GP) {
								col.a *= 1-((abs(gp.x-0.5)-_GP)/(0.5-_GP));
							}
							if(abs(gp.y-0.5) > _GP) {
								col.a *= 1-((abs(gp.y-0.5)-_GP)/(0.5-_GP));
							}
							break;
						}
					}
					gp = ComputeGrabScreenPos(UnityObjectToClipPos(i.rvp));
					fixed4 bcol = tex2Dproj(_GpRef, gp);
					col.xyz = lerp(bcol.xyz, col.xyz, col.a);
					col.a = 1;
					if(luv > _MN) {
						col.a = 1-((luv-_MN)/(_MX-_MN));
					}
					return col;
				}
			}
			ENDCG
		}
	}
}

/*
#define MAX_RADIUS 2

// Set to 1 to hash twice. Slower, but less patterns.
#define DOUBLE_HASH 0

// Hash functions shamefully stolen from:
// https://www.shadertoy.com/view/4djSRW
#define HASHSCALE1 .1031
#define HASHSCALE3 vec3(.1031, .1030, .0973)

float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * HASHSCALE1);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * HASHSCALE3);
    p3 += dot(p3, p3.yzx+19.19);
    return fract((p3.xx+p3.yz)*p3.zy);

}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float resolution = 10. * exp2(-3.*iMouse.x/iResolution.x);
	vec2 uv = fragCoord.xy / iResolution.y * resolution;
    vec2 p0 = floor(uv);

    vec2 circles = vec2(0.);
    for (int j = -MAX_RADIUS; j <= MAX_RADIUS; ++j)
    {
        for (int i = -MAX_RADIUS; i <= MAX_RADIUS; ++i)
        {
			vec2 pi = p0 + vec2(i, j);
            #if DOUBLE_HASH
            vec2 hsh = hash22(pi);
            #else
            vec2 hsh = pi;
            #endif
            vec2 p = pi + hash22(hsh);

            float t = fract(0.3*iTime + hash12(hsh));
            vec2 v = p - uv;
            float d = length(v) - (float(MAX_RADIUS) + 1.)*t;

            float h = 1e-3;
            float d1 = d - h;
            float d2 = d + h;
            float p1 = sin(31.*d1) * smoothstep(-0.6, -0.3, d1) * smoothstep(0., -0.3, d1);
            float p2 = sin(31.*d2) * smoothstep(-0.6, -0.3, d2) * smoothstep(0., -0.3, d2);
            circles += 0.5 * normalize(v) * ((p2 - p1) / (2. * h) * (1. - t) * (1. - t));
        }
    }
    circles /= float((MAX_RADIUS*2+1)*(MAX_RADIUS*2+1));

    float intensity = 0.005;
    vec3 n = vec3(circles, sqrt(1. - dot(circles, circles)));
    vec3 color = texture(iChannel0, uv/resolution - intensity*n.xy).rgb;
	fragColor = vec4(color, 1.0);
}
*/
