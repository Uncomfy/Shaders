Shader "SCP/SetData"
{
	Properties {
		_Mn("Min", Range(-1.0, 1.0)) = 0.0
	}
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry+2147481647" }
        Cull Front
        ZTest Always
		Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 rvp : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata_base v) {
                v2f o;
                // use UnityObjectToClipPos from UnityCG.cginc to calculate 
                // the clip-space of the vertex
                o.pos = UnityObjectToClipPos(v.vertex);
                // use ComputeGrabScreenPos function from UnityCG.cginc
                // to get the correct texture coordinate
                o.rvp = v.vertex;
                return o;
            }

            sampler2D _GetData;
			float _Mn;

            float4 frag(v2f i) : SV_Target
			{
				float4 gp = ComputeGrabScreenPos(UnityObjectToClipPos(i.rvp));
				float3 cPos;
				#if UNITY_SINGLE_PASS_STEREO
					cPos = (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1])/2;
				#else
					cPos = _WorldSpaceCameraPos;
				#endif
				float2 rgrab = gp.xy/gp.w;
                float3 pos = tex2D(_GetData, float2(0.045,0.5)).rgb;
                float3 pdir = tex2D(_GetData, float2(0.955,0.5)).rgb;
				float3 vdir = normalize(mul(unity_CameraToWorld, float4(0,0,1,1)).xyz-cPos);
				float3 ldir = normalize(pos-cPos);
				if(rgrab.x > 0.043 && rgrab.x < 0.047 && rgrab.y < 0.503 && rgrab.y > 0.497) {
					if(dot(vdir, ldir) <= _Mn) {
						return fixed4(cPos+2*ldir, 1);
					} else {
						return fixed4(pos, 1);
					}
                } else if(rgrab.x > 0.953 && rgrab.x < 0.957 && rgrab.y < 0.503 && rgrab.y > 0.497) {
					if(dot(vdir, ldir) <= _Mn) {
						return fixed4(-ldir, 1);
					} else {
						return fixed4(pdir, 1);
					}
                }
				return fixed4(0,0,0,0);
            }
            ENDCG
        }

    }
}