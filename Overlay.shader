Shader "Unlit/Overlay"
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
		[Toggle] _Cicada("Cicada", int) = 0
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
			int _Cicada;
			
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
				col += tex2D(_MainTex, TRANSFORM_TEX(wpos.yz, _MainTex))*normal.x*normal.x;
				col += tex2D(_MainTex, TRANSFORM_TEX(wpos.xz, _MainTex))*normal.y*normal.y;
				col += tex2D(_MainTex, TRANSFORM_TEX(wpos.xy, _MainTex))*normal.z*normal.z;
				if(_Cicada == 1) {
					float3 wpos1 = wpos*17.0/41.0;
					fixed4 col1 = 0;
					col1 += tex2D(_MainTex, TRANSFORM_TEX(wpos1.yz, _MainTex))*normal.x*normal.x;
					col1 += tex2D(_MainTex, TRANSFORM_TEX(wpos1.xz, _MainTex))*normal.y*normal.y;
					col1 += tex2D(_MainTex, TRANSFORM_TEX(wpos1.xy, _MainTex))*normal.z*normal.z;
					col = col*0.5+col1*0.5;
				}
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