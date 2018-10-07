Shader "Unlit/ZoomSlider"
{
	Properties
	{
		_MX ("Zoom", Range(0.0, 1.0)) = 0.0
		_MD ("Min dm", float) = 0.5
	}
	SubShader
	{
		Tags { "RenderType"="Overlay" "Queue"="Overlay"}
		LOD 100
		Cull Front
		ZTest Always
		GrabPass { "_Zoom" }

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
			};

			struct v2f
			{
				float4 rvp : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};
			
			sampler2D _Zoom;
			float _MX;
			float _MD;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.rvp = v.vertex;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 scrPos = ComputeGrabScreenPos(UnityObjectToClipPos(i.rvp));
				scrPos/=scrPos.w;
				float4 zerPos = ComputeGrabScreenPos(UnityObjectToClipPos(float4(0,0,0,1)));
				zerPos/=zerPos.w;
				#if UNITY_SINGLE_PASS_STEREO
					float3 wnorm = normalize(unity_StereoWorldSpaceCameraPos[1] - unity_StereoWorldSpaceCameraPos[0]);
					float3 vdir = mul(unity_CameraToWorld, float4(0,0,1,1)).xyz-_WorldSpaceCameraPos;
					vdir = vdir-dot(wnorm,vdir)*wnorm;
					float3 cPos = (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1])/2;
					float3 odir = mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz-cPos;
				#else
					float3 vdir = mul(unity_CameraToWorld, float4(0,0,1,1)).xyz-_WorldSpaceCameraPos;
					float3 odir = mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz-_WorldSpaceCameraPos;
				#endif
				float dm = dot(normalize(vdir), normalize(odir));
				if(dm > _MD) {
					dm = (dm-_MD)/(1-_MD);
				} else {
					dm = 0;
				}
				fixed4 col = tex2D(_Zoom, lerp(scrPos.xy, zerPos.xy, _MX*dm));
				return col;
			}
			ENDCG
		}
	}
}
