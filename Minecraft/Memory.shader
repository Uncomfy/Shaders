Shader "Minecraft/Memory"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_PosTex ("Position Texture", 2D) = "white" {}
		_CurItem ("Cur Item", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
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

			sampler2D _MainTex;
			sampler2D _PosTex;
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
				float2 ruv = floor(i.uv*float2(128.0, 16.0));
				float2 cuv;
				cuv.x = fmod(ruv.x, 16.0);
				cuv.y = ruv.y;
				int id = int(ruv.x/16.0);
				cuv = (cuv+0.5)/float2(16.0,16.0);
				ruv = (ruv+0.5)/float2(128.0, 16.0);
				fixed4 prv = tex2D(_MainTex, ruv);
				float pos = tex2D(_PosTex, cuv).r;
				if(pos > 0 && int(pos*8)==id) {
					prv = tex2D(_CurItem, float2(0.5,0.5));
				}
				return prv;
			}
			ENDCG
		}
	}
}
