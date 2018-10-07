Shader "Unlit/Chromatic"
{
	Properties
	{
		[HideInInspector]_MainTex ("Texture", 2D) = "white" {}
		_MX ("Fade Distance", float) = 3.0
		_SS ("Sphere Radius", float) = 5.0
		_DM ("Strength", float) = 0.1
	}
	SubShader
	{
		Tags { "RenderType"="Overlay" "Queue" = "Overlay+1000"}
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		ZTest Always
		Cull Front
		GrabPass { "_GPChroma" }

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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 rvp : TEXCOORD1;
			};

			sampler2D _MainTex;
			sampler2D _GPChroma;
			float _MX;
			float _SS;
			float _DM;
			
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
				float3 cmr;
				#if UNITY_SINGLE_PASS_STEREO
					cmr = (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1])/2;
				#else
					cmr = _WorldSpaceCameraPos;
				#endif
				float dst = distance(cmr, mul(unity_ObjectToWorld, float4(0,0,0,1)));
				if(dst < _MX+_SS) {
					float4 gp = ComputeGrabScreenPos(UnityObjectToClipPos(i.rvp));
					float2 uv = gp.xy/gp.w;
					float2 cntr;
					#if UNITY_SINGLE_PASS_STEREO
						if(unity_StereoEyeIndex == 0) {
							cntr = float2(0.25, 0.5);
						} else {
							cntr = float2(0.75, 0.5);
						}
					#else
						cntr = float2(0.5,0.5);
					#endif
					float2 uvd = uv-cntr;
					float ml;
					if(dst>_SS) {
						ml = 1.0-(dst-_SS)/_MX;
					} else {
						ml = 1.0;
					}
					fixed4 col;
					col.r = tex2D(_GPChroma, uvd*(1+_DM*ml)+cntr).r;
					col.g = tex2D(_GPChroma, uv).g;
					col.b = tex2D(_GPChroma, uvd*(1-_DM*ml)+cntr).b;
					col.a = 1.0;
					return col;
				} else {
					return fixed4(0,0,0,0);
				}
			}
			ENDCG
		}
	}
}
