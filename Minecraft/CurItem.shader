Shader "Minecraft/CurItem"
{
	Properties
	{
		_Item1 ("Item 1", 2D) = "white" {}
		_Item2 ("Item 2", 2D) = "white" {}
		_Item3 ("Item 3", 2D) = "white" {}
		_Item4 ("Item 4", 2D) = "white" {}
		_Item5 ("Item 5", 2D) = "white" {}
		_Prv ("Previous", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		LOD 100

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
				float4 vertex : SV_POSITION;
			};

			sampler2D _Item1;
			sampler2D _Item2;
			sampler2D _Item3;
			sampler2D _Item4;
			sampler2D _Item5;
			sampler2D _Prv;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				if(tex2D(_Item1, float2(0.5, 0.5)).r > 0.1) {
					return fixed4(0,0,0,1);
				} else if(tex2D(_Item2, float2(0.5, 0.5)).r > 0.1) {
					return fixed4(1,0,0,1);
				} else if(tex2D(_Item3, float2(0.5, 0.5)).r > 0.1) {
					return fixed4(0,1,0,1);
				} else if(tex2D(_Item4, float2(0.5, 0.5)).r > 0.1) {
					return fixed4(1,1,0,1);
				} else if(tex2D(_Item5, float2(0.5, 0.5)).r > 0.1) {
					return fixed4(0,0,1,1);
				} else {
					return tex2D(_Prv, float2(0.5, 0.5));
				}
			}
			ENDCG
		}
	}
}
