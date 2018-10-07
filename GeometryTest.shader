Shader "Unlit/GeometryTest"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MV("Move", float) = 0.0
		_AM("Alpha Multiplier", float) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			Cull Off
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
			};

			sampler2D _MainTex;
			float _MV;
			float _AM;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				return fixed4(1,1,1,col.a);
			}
			ENDCG
		}

		Pass
		{
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
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
			};

			sampler2D _MainTex;
			float _MV;
			float _AM;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = v.vertex;
				o.uv = v.uv;
				return o;
			}

			[maxvertexcount(3)]
			void geom(triangle v2f IN[3], inout TriangleStream<v2f> tristream)
            {
				v2f o;
				float3 norm = normalize(cross(IN[1].vertex.xyz-IN[0].vertex.xyz, IN[2].vertex.xyz-IN[0].vertex.xyz));
				float x;
				for(int i = 0; i < 3; i++) {
					o = IN[i];
					x = o.vertex.x*_MV;
					if(x < 0) {
						x = 0;
					}
					o.vertex.xyz+=norm*x;
					o.vertex = UnityObjectToClipPos(o.vertex);
					tristream.Append(o);
				}
                tristream.RestartStrip();
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				col.a*=_AM;
				return col;
			}
			ENDCG
		}
	}
}
