Shader "Minecraft/RenderItems"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_CurItem ("Cur Item", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha

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

			sampler2D _MainTex;
			sampler2D _CurItem;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				float x = i.uv.x*5;
				fixed4 cur = tex2D(_CurItem, float2(0.5,0.5));
				int id = 0;
				if(cur.r > 0.5) {
					id+=1;
				}
				if(cur.g > 0.5) {
					id+=2;
				}
				if(cur.b > 0.5) {
					id+=4;
				}
				if(int(x) == id && (frac(x) < 0.05 || frac(x) > 0.95 || i.uv.y < 0.05 || i.uv.y > 0.95)) {
					return fixed4(0,1,0,1);
				} else if(frac(x) < 0.05 || frac(x) > 0.95 || i.uv.y < 0.05 || i.uv.y > 0.95) {
					return fixed4(1,0,0,1);
				}
				return col;
			}
			ENDCG
		}
	}
}
