Shader "Unlit/OverlayVoronoi"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		//_TexMul ("Texture Multiplier", float) = 1.0
		//_MxDis ("Max Distance", float) = 1.0
		_Offset ("Border offset", float) = 0.5
		[Toggle] _IsRising("Increase border with time?", int) = 0
		[Toggle] _IsLocal("Is Local?", int) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Overlay+2000000000"}
		LOD 100
		Cull Front
		ZTest Always
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				float3 sz : TEXCOORD1;
			};

			struct v2f
			{
				float4 uv : TEXCOORD2;
				float3 ray : TEXCOORD1;
				float4 tm : TEXCOORD0;
				float3 sz : TEXCOORD3;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			sampler2D_float _CameraDepthTexture;
			//float _TexMul;
			//float _MxDis;
			float _Offset;
			int _IsRising;
			int _IsLocal;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = ComputeGrabScreenPos(o.vertex);
				o.ray = UnityObjectToViewPos(v.vertex).xyz * float3(-1,-1,1);
				if(_IsLocal == 0) {
					o.tm = v.uv;
				} else {
					o.tm = float4(mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz,v.uv.w);
				}
				o.sz = v.sz/2;
				//o.ray = lerp(o.ray, v.uv, v.uv.z != 0);
				return o;
			}

			float msignz(float2 coor) {
				if(coor.x >= 0 && coor.y >= 0) {
					return -1;
				} else if(coor.x >= 0 && coor.y < 0) {
					return 1;
				} else if(coor.x < 0 && coor.y < 0) {
					return -1;
				} else {
					return 1;
				}
			}
			
			float2 rotate(float2 p, float a)
			{
				return float2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
			}

			// 1D random numbers
			float rand(float n)
			{
				return frac(sin(n) * 43758.5453123);
			}

			// 2D random numbers
			float2 rand2(float2 p)
			{
				return frac(float2(sin(p.x * 591.32 + p.y * 154.077), cos(p.x * 391.32 + p.y * 49.077)));
			}

			// 1D noise
			float noise1(float p)
			{
				float fl = floor(p);
				float fc = frac(p);
				return lerp(rand(fl), rand(fl + 1.0), fc);
			}

			// voronoi distance noise, based on iq's articles
			float voronoi(float2 x)
			{
				float2 p = floor(x);
				float2 f = frac(x);
				
				float2 res = float2(8.0, 8.0);
				for(int j = -1; j <= 1; j ++)
				{
					for(int i = -1; i <= 1; i ++)
					{
						float2 b = float2(i, j);
						float2 r = float2(b) - f + rand2(p + b);
						
						// chebyshev distance, one of many ways to do this
						float d = max(abs(r.x), abs(r.y));
						
						if(d < res.x)
						{
							res.y = res.x;
							res.x = d;
						}
						else if(d < res.y)
						{
							res.y = d;
						}
					}
				}
				return res.y - res.x;
			}
			
			fixed4 voron (float2 iuv) : SV_Target
			{
				float iTime = _Time.y;
				float flicker = noise1(iTime * 2.0) * 0.8 + 0.4;

				float2 uv = iuv;
				//uv = (uv - 0.5) * 2.0;
				float2 suv = uv;
				
				
				float v = 0.0;
				
				// that looks highly interesting:
				//v = 1.0 - length(uv) * 1.3;
				
				
				// a bit of camera movement
				/*uv *= 0.6 + sin(iTime * 0.1) * 0.4;
				uv = rotate(uv, sin(iTime * 0.3) * 1.0);
				uv += iTime * 0.4;*/
				
				
				// add some noise octaves
				float a = 0.6, f = 1.0;
				
				for(int i = 0; i < 3; i ++) // 4 octaves also look nice, its getting a bit slow though
				{	
					float v1 = voronoi(uv * f + 5.0);
					float v2 = 0.0;
					
					// make the moving electrons-effect for higher octaves
					if(i > 0)
					{
						// of course everything based on voronoi
						v2 = voronoi(uv * f * 0.5 + 50.0 + iTime);
						
						float va = 0.0, vb = 0.0;
						va = 1.0 - smoothstep(0.0, 0.1, v1);
						vb = 1.0 - smoothstep(0.0, 0.08, v2);
						v += a * pow(va * (0.5 + vb), 2.0);
					}
					
					// make sharp edges
					v1 = 1.0 - smoothstep(0.0, 0.3, v1);
					
					// noise is used as intensity map
					v2 = a * (noise1(v1 * 5.5 + 0.1));
					
					// octave 0's intensity changes a bit
					if(i == 0)
						v += v2 * flicker;
					else
						v += v2;
					
					f *= 3.0;
					a *= 0.7;
				}

				// slight vignetting
				//v *= exp(-0.6 * length(suv)) * 1.2;
				v*=0.6;
				
				// use texture channel0 for color? why not.
				float3 cexp = float3(4.0, 2.0, 1.0);//tex2D(iChannel0, uv * 0.001).xyz * 3.0 + tex2D(iChannel0, uv * 0.01).xyz;//float3(1.0, 2.0, 4.0);
				cexp *= 1.4;
				
				// old blueish color set
				//vec3 cexp = vec3(6.0, 4.0, 2.0);
				
				float3 col = float3(pow(v, cexp.x), pow(v, cexp.y), pow(v, cexp.z)) * 2.0;
				return fixed4(col,1);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				// apply fog
				//i.scrPos/=i.scrPos.w;
				float rawDepth = DecodeFloatRG(tex2Dproj(_CameraDepthTexture, i.uv));
				float linearDepth = Linear01Depth(rawDepth);
				i.ray *= (_ProjectionParams.z / i.ray.z);
				float4 vpos = float4(i.ray * linearDepth, 1);
				float3 wpos = mul(unity_CameraToWorld, vpos).xyz;
				float3 normal = normalize(cross(ddx(wpos), ddy(wpos)));
//				float2 ruv;
//				float3 nx;
//				nx.y = 0;
//				if(abs(normal.y) > 0.99) {
//					nx.x = 1;
//					nx.z = 0;
//				} else {
//					nx.z = msignz(float2(normal.x, normal.z))*abs(normal.x/sqrt(normal.x*normal.x+normal.z*normal.z));
//					nx.x = sqrt(1-nx.z*nx.z);
//				}
//				float3 ny = normalize(cross(normal, nx));
//				ruv.x = dot(wpos, nx);
//				ruv.y = dot(wpos, ny);
//				fixed4 col = tex2D(_MainTex, ruv*_TexMul);
				fixed4 col = 0;
				col += voron(wpos.yz)*normal.x*normal.x;
				col += voron(wpos.xz)*normal.y*normal.y;
				col += voron(wpos.xy)*normal.z*normal.z;
				col*=_Color;
				float dsc = distance(wpos, i.tm.xyz);
				if(_IsRising == 1) {
					_Offset*=i.tm.w;
				}
				if(_Offset > length(i.sz)) {
					_Offset = length(i.sz);
				}
				float3 oof = wpos-i.tm.xyz;
				if(length((length(oof)+_Offset)*normalize(oof)/i.sz) < 1) {
					//col.a = 1;
				} else if(length(oof/i.sz) < 1) {
					/*float md = length(((normalize(oof)*i.sz)-_Offset)/i.sz);
					col.a *= 1-(length(oof/i.sz)-md)/(1-md);*/
					float3 mx = normalize(oof/i.sz)*i.sz;
					float3 mn = (length(mx)-_Offset)*normalize(mx);
					col.a *= 1-((length(oof)-length(mn))/(length(mx)-length(mn)));
				} else {
					col.a = 0;
				}
				return col;
			}
			ENDCG
		}
	}
}
//x1*x2+z1*z2=0		x1*x2 = -z1*z2		x1*x1*x2*x2 = z1*z1*z2*z2	x1*x1*(1-z2*z2) = z1*z1*z2*z2	(z1*z1+x1*x1)/x1*x1 = 1/z2*z2		z2 = sqrt(x1*x1/(x1*x1+z1*z1))
//x2*x2+z2*z2=1		x2 = sqrt(1-z2*z2)