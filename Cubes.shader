Shader "Unlit/MCubes"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Sc ("Scale", float) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		LOD 100
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			
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
			float _Sc;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(unity_ObjectToWorld,v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			[maxvertexcount(36)]
			void geom(triangle v2f IN[3], inout TriangleStream<v2f> tristream)
            {
				float4 cnt = (IN[0].vertex+IN[1].vertex+IN[2].vertex)/3.0;
				cnt = floor(cnt*_Sc)/_Sc;
				float oned = 1.0/_Sc;
				v2f ans;
				ans.uv = (IN[0].uv+IN[1].uv+IN[2].uv)/3.0;
				ans.vertex = mul(UNITY_MATRIX_VP, cnt);
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned, oned, 0, 0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned, 0, 0, 0));
				tristream.Append(ans);
				tristream.RestartStrip();
				ans.vertex = mul(UNITY_MATRIX_VP, cnt);
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned, oned, 0, 0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(0, oned, 0, 0));
				tristream.Append(ans);
				tristream.RestartStrip();
				ans.vertex = mul(UNITY_MATRIX_VP, cnt);
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned, 0, oned, 0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned, 0, 0, 0));
				tristream.Append(ans);
				tristream.RestartStrip();
				ans.vertex = mul(UNITY_MATRIX_VP, cnt);
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned, 0, oned, 0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(0, 0, oned, 0));
				tristream.Append(ans);
				tristream.RestartStrip();
				ans.vertex = mul(UNITY_MATRIX_VP, cnt);
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(0, oned, oned, 0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(0, oned, 0, 0));
				tristream.Append(ans);
				tristream.RestartStrip();
				ans.vertex = mul(UNITY_MATRIX_VP, cnt);
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(0, oned, oned, 0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(0, 0, oned, 0));
				tristream.Append(ans);
				tristream.RestartStrip();
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(0,0,oned,0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned, oned, oned, 0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned, 0, oned, 0));
				tristream.Append(ans);
				tristream.RestartStrip();
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(0,0,oned,0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned, oned, oned, 0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(0, oned, oned, 0));
				tristream.Append(ans);
				tristream.RestartStrip();
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(0,oned,0,0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned, oned, oned, 0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned, oned, 0, 0));
				tristream.Append(ans);
				tristream.RestartStrip();
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(0,oned,0,0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned, oned, oned, 0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(0, oned, oned, 0));
				tristream.Append(ans);
				tristream.RestartStrip();
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned,0,0,0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned, oned, oned, 0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned, oned, 0, 0));
				tristream.Append(ans);
				tristream.RestartStrip();
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned,0,0,0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned, oned, oned, 0));
				tristream.Append(ans);
				ans.vertex = mul(UNITY_MATRIX_VP, cnt+float4(oned, 0, oned, 0));
				tristream.Append(ans);
				tristream.RestartStrip();
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
