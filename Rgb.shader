Shader "Custom/RGB"
{
	Properties
	{
		_Str("Strength", float) = 0.1
		_Spd("Speed", float) = 50
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Overlay" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull Off
		ZTest Always
		GrabPass{ 
			"_GrabTextureMy"
		}
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float4 screenPos;
		};

		uniform sampler2D _GrabTextureMy;
		float _Str;
		float _Spd;

		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		inline fixed4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return fixed4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 transform20 = mul(unity_WorldToObject,float4( 0,0,0,1 ));
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float mvc = sin(_Time.x*_Spd)*_Str;
			float screenColorRed = tex2D( _GrabTextureMy, ase_grabScreenPosNorm.xy + mvc*float2(-0.77, 0.77)).r;
			float screenColorGreen = tex2D( _GrabTextureMy, ase_grabScreenPosNorm.xy + mvc*float2(0.77, 0.77)).g;
			float screenColorBlue = tex2D( _GrabTextureMy, ase_grabScreenPosNorm.xy  + mvc*float2(0, -1)).b;
			o.Emission = float3(screenColorRed, screenColorGreen, screenColorBlue);
			o.Alpha = 1;
		}

		ENDCG
	}
}