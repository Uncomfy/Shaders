Shader "SCP/Draw"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Vec ("Offset", Vector) = (0,0,0,1)
		_TV ("TV", Vector) = (0,0,0,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
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
			sampler2D _GetData;
			float4 _Vec;
			float4 _TV;
			
			v2f vert (appdata v)
			{
				v2f o;
				v.vertex.yz = float2(v.vertex.z, -v.vertex.y);
				v.vertex/=100;
				v.vertex = mul(unity_ObjectToWorld, v.vertex);
				float3 rvec = tex2Dlod(_GetData, float4(0.955,0.5,0,0));
				float3 vodir = mul(unity_WorldToObject, float4(rvec.xyz+mul(unity_ObjectToWorld, _Vec).xyz, 1)).xyz;
				float3 xrot = normalize(float3(vodir.x, 0, vodir.z));
				float2x2 mtr = float2x2( xrot.z, -xrot.x, xrot.x, xrot.z);
				v.vertex.xz = mul(v.vertex.xz, mtr);
                float3 pos = tex2Dlod(_GetData, float4(0.045,0.5,0,0)).xyz;
				v.vertex.xyz += pos-mul(unity_ObjectToWorld, _Vec).xyz-_TV.xyz;
				v.vertex = mul(unity_WorldToObject, v.vertex);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
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
