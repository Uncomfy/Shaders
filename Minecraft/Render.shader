Shader "Minecraft/Render"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Dirt ("Dirt", 2D) = "white" {}
		_Stone ("Stone", 2D) = "white" {}
		_Planks ("Planks", 2D) = "white" {}
		_Glass ("Glass", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Overlay" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha
		//ZTest Always

		// Pass
		// {
			// Cull Back
			// CGPROGRAM
			// #pragma vertex vert
			// #pragma fragment frag
			
			// #include "UnityCG.cginc"

			// struct appdata
			// {
				// float4 vertex : POSITION;
				// float2 uv : TEXCOORD0;
			// };

			// struct v2f
			// {
				// float2 uv : TEXCOORD0;
				// float4 rvp : TEXCOORD1;
				// float4 vertex : SV_POSITION;
			// };

			// sampler2D _MainTex;
			// sampler2D _Dirt;
			// sampler2D _Stone;
			// sampler2D _Planks;
			// sampler2D _Glass;
			
			// v2f vert (appdata v)
			// {
				// v2f o;
				// o.vertex = UnityObjectToClipPos(v.vertex);
				// o.uv = v.uv;
				// o.rvp = v.vertex;
				// return o;
			// }
			
			// fixed4 frag (v2f i) : SV_Target
			// {
				// float thick = 0.495;
				// float3 pos = i.rvp.xyz;
				// float3 ray = normalize(ObjSpaceViewDir(i.rvp));
				// float xdis, ydis, zdis;
				// float3 xvec, yvec, zvec;
				// /*while(abs(pos.x)>0.5 || abs(pos.y)>0.5 || abs(pos.y)>0.5) {
					// if(ray.x > 0) {
						// xvec = ray*(ceil(pos.x+0.001)-pos.x)/ray.x;
					// } else {
						// xvec = ray*(floor(pos.x-0.001)-pos.x)/ray.x;
					// }
					// if(ray.y > 0) {
						// yvec = ray*(ceil(pos.y+0.001)-pos.y)/ray.y;
					// } else {
						// yvec = ray*(floor(pos.y-0.001)-pos.y)/ray.y;
					// }
					// if(ray.z > 0) {
						// zvec = ray*(ceil(pos.z+0.001)-pos.z)/ray.z;
					// } else {
						// zvec = ray*(floor(pos.z-0.001)-pos.z)/ray.z;
					// }
					// xdis = length(xvec);
					// ydis = length(yvec);
					// zdis = length(zvec);
					// if(xdis <= ydis && xdis <= zdis) {
						// pos+=ray*xdis;
					// } else if(ydis <= xdis && ydis <= zdis) {
						// pos+=ray*ydis;
					// } else {
						// pos+=ray*zdis;
					// }
				// }
				// return fixed4(pos,1);*/
				// pos+=0.5;
				// pos*=8.0;//float3(4.0, 2.0, 4.0);
				// pos.y/=2.0;
				// float3 rvp = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0)).xyz+0.5;
				// rvp*=8.0;
				// rvp.y/=2.0;
				// ray = normalize(pos-rvp);
				// pos-=ray*0.01;
				// fixed4 col = fixed4(0,0,0,0);
				// int cid;
				// float2 tuv;
				// float3 tpos;
				// fixed4 tcol;
				// int texid;
				// int k = 0;
				// bool IGB = false;
				// while(!((pos.x <= 0 && ray.x < 0) || (pos.x >= 8 && ray.x > 0) || (pos.y <= 0 && ray.y < 0) || (pos.y >= 4 && ray.y > 0) || (pos.z <= 0 && ray.z < 0) || (pos.z >= 8 && ray.z > 0))) {
					// k++;
					// if(k > 100) {
						// col = fixed4(0.5,0.5,0.5,1.0);
						// break;
					// }
					// if(ray.x > 0) {
						// xvec = ray*(ceil(pos.x+0.001)-(pos.x))/ray.x;
						// xdis = length(xvec);
					// } else {
						// xvec = ray*(floor(pos.x-0.001)-(pos.x))/ray.x;
						// xdis = length(xvec);
					// }
					// if(ray.y > 0) {
						// yvec = ray*(ceil(pos.y+0.001)-(pos.y))/ray.y;
						// ydis = length(yvec);
					// } else {
						// yvec = ray*(floor(pos.y-0.001)-(pos.y))/ray.y;
						// ydis = length(yvec);
					// }
					// if(ray.z > 0) {
						// zvec = ray*(ceil(pos.z+0.001)-(pos.z))/ray.z;
						// zdis = length(zvec);
					// } else {
						// zvec = ray*(floor(pos.z-0.001)-(pos.z))/ray.z;
						// zdis = length(zvec);
					// }
					// if(xdis <= ydis && xdis <= zdis) {
						// pos+=xvec;
						// cid = 0;
					// } else if(ydis <= xdis && ydis <= zdis) {
						// pos+=yvec;
						// cid = 1;
					// } else {
						// pos+=zvec;
						// cid = 2;
					// }
					// if((pos.x <= 0 && ray.x < 0) || (pos.x >= 8 && ray.x > 0) || (pos.y <= 0 && ray.y < 0) || (pos.y >= 4 && ray.y > 0) || (pos.z <= 0 && ray.z < 0) || (pos.z >= 8 && ray.z > 0)) {
						// continue;
					// }
					// if(ray.x > 0) {
						// tpos.x = floor(pos.x+0.001);
					// } else {
						// tpos.x = floor(pos.x-0.001);
					// }
					// if(ray.y > 0) {
						// tpos.y = floor(pos.y+0.001);
					// } else {
						// tpos.y = floor(pos.y-0.001);
					// }
					// if(ray.z > 0) {
						// tpos.z = floor(pos.z+0.001);
					// } else {
						// tpos.z = floor(pos.z-0.001);
					// }
					// /*if(tpos.y == 0 && tpos.x == 3 && tpos.z == 0) {
						// return fixed4(1,0,0,1);
					// }*/
					// tuv.x = (tpos.y*8.0 + tpos.x + 0.5)/32.0;
					// tuv.y = (tpos.z+0.5)/8.0;
					// if(tuv.x >= 1 || tuv.x < 0 || tuv.y >= 1 || tuv.y < 0) {
						// continue;
					// }
					// tcol = tex2Dlod(_MainTex, float4(tuv,0,0));
					// texid = 0;
					// if(tcol.r > 0.5) {
						// texid+=1;
					// }
					// if(tcol.g > 0.5) {
						// texid+=2;
					// }
					// if(tcol.b > 0.5) {
						// texid+=4;
					// }
					// if(cid == 0) {
						// tuv = pos.zy;
					// } else if(cid == 1) {
						// tuv = pos.xz;
					// } else {
						// tuv = pos.xy;
					// }
					// if(texid == 1) {
						// col = tex2Dlod(_Dirt, float4(tuv, 0,0));
						// break;
					// } else if(texid == 2) {
						// col = tex2Dlod(_Stone, float4(tuv, 0,0));
						// break;
					// } else if(texid == 3) {
						// col = tex2Dlod(_Planks, float4(tuv, 0,0));
						// break;
					// } else if(texid == 4) {
						// if(IGB == 0) {
							// col = tex2Dlod(_Glass, float4(tuv, 0,0));
							// if(col.a > 0.8) {
								// break;
							// }
						// }
					// }
					// if(texid == 4) {
						// IGB = 1;
					// }
				// }
				// if(col.a <= 0.8) {
					// if((abs(i.rvp.x) > thick && abs(i.rvp.y) > thick) || (abs(i.rvp.x) > thick && abs(i.rvp.z) > thick) || (abs(i.rvp.y) > thick && abs(i.rvp.z) > thick)) {
						// return fixed4(1,1,1,1);
					// }
				// }
				// return col;
			// }
			// ENDCG
		// }
		
		Pass
		{
			Cull Front
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
				float4 rvp : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};
			
			struct fOut
			{
				fixed4 col : COLOR;
				float dp : DEPTH;
			};
			
			sampler2D _MainTex;
			sampler2D _Dirt;
			sampler2D _Stone;
			sampler2D _Planks;
			sampler2D _Glass;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.rvp = v.vertex;
				return o;
			}
			
			fOut frag (v2f i)
			{
				//return fixed4(i.rvp.xyz+0.5, 1);
				fOut o;
				float thick = 0.495;
				float3 pos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0)).xyz;
				float3 ray = normalize(i.rvp.xyz-pos);
				float xdis, ydis, zdis;
				float3 xvec, yvec, zvec;
				if(abs(pos.x)>0.5 || abs(pos.y)>0.5 || abs(pos.y)>0.5) {
					pos = i.rvp.xyz;
					ray = -ray;
					if(ray.x > 0) {
						xvec = ray*(0.5-pos.x)/ray.x;
					} else {
						xvec = ray*(-0.5-pos.x)/ray.x;
					}
					if(ray.y > 0) {
						yvec = ray*(0.5-pos.y)/ray.y;
					} else {
						yvec = ray*(-0.5-pos.y)/ray.y;
					}
					if(ray.z > 0) {
						zvec = ray*(0.5-pos.z)/ray.z;
					} else {
						zvec = ray*(-0.5-pos.z)/ray.z;
					}
					xdis = length(xvec);
					ydis = length(yvec);
					zdis = length(zvec);
					if(xdis <= ydis && xdis <= zdis) {
						//return fixed4(1,1,1,1);
						pos+=xvec*1.1;
					} else if(ydis <= xdis && ydis <= zdis) {
						pos+=yvec*1.1;
					} else {
						pos+=zvec*1.1;
					}
				}
				pos+=0.5;
				pos*=16.0;//float3(4.0, 2.0, 4.0);
				pos.y/=2.0;
				float3 rvp = i.rvp+0.5;
				rvp*=16.0;
				rvp.y/=2.0;
				ray = normalize(rvp-pos);
				//return fixed4(ray, 1);
				fixed4 col = fixed4(0,0,0,0);
				int cid;
				float2 tuv;
				float3 tpos;
				fixed4 tcol;
				int texid;
				int k = 0;
				bool IGB = false;
				while(!((pos.x <= 0 && ray.x < 0) || (pos.x >= 16 && ray.x > 0) || (pos.y <= 0 && ray.y < 0) || (pos.y >= 8 && ray.y > 0) || (pos.z <= 0 && ray.z < 0) || (pos.z >= 16 && ray.z > 0))) {
					k++;
					if(k > 100) {
						col = fixed4(0.5,0.5,0.5,1.0);
						break;
					}
					if(ray.x > 0) {
						xvec = ray*(ceil(pos.x+0.001)-(pos.x))/ray.x;
						xdis = length(xvec);
					} else {
						xvec = ray*(floor(pos.x-0.001)-(pos.x))/ray.x;
						xdis = length(xvec);
					}
					if(ray.y > 0) {
						yvec = ray*(ceil(pos.y+0.001)-(pos.y))/ray.y;
						ydis = length(yvec);
					} else {
						yvec = ray*(floor(pos.y-0.001)-(pos.y))/ray.y;
						ydis = length(yvec);
					}
					if(ray.z > 0) {
						zvec = ray*(ceil(pos.z+0.001)-(pos.z))/ray.z;
						zdis = length(zvec);
					} else {
						zvec = ray*(floor(pos.z-0.001)-(pos.z))/ray.z;
						zdis = length(zvec);
					}
					if(xdis <= ydis && xdis <= zdis) {
						pos+=xvec;
						cid = 0;
					} else if(ydis <= xdis && ydis <= zdis) {
						pos+=yvec;
						cid = 1;
					} else {
						pos+=zvec;
						cid = 2;
					}
					if((pos.x <= 0 && ray.x < 0) || (pos.x >= 16 && ray.x > 0) || (pos.y <= 0 && ray.y < 0) || (pos.y >= 8 && ray.y > 0) || (pos.z <= 0 && ray.z < 0) || (pos.z >= 16 && ray.z > 0)) {
						continue;
					}
					if(ray.x > 0) {
						tpos.x = floor(pos.x+0.001);
					} else {
						tpos.x = floor(pos.x-0.001);
					}
					if(ray.y > 0) {
						tpos.y = floor(pos.y+0.001);
					} else {
						tpos.y = floor(pos.y-0.001);
					}
					if(ray.z > 0) {
						tpos.z = floor(pos.z+0.001);
					} else {
						tpos.z = floor(pos.z-0.001);
					}
					/*if(tpos.y == 0 && tpos.x == 3 && tpos.z == 0) {
						return fixed4(1,0,0,1);
					}*/
					tuv.x = (tpos.y*16.0 + tpos.x + 0.5)/128.0;
					tuv.y = (tpos.z+0.5)/16.0;
					if(tuv.x >= 1 || tuv.x < 0 || tuv.y >= 1 || tuv.y < 0 || tpos.x+0.5 > 16 || tpos.x < 0) {
						continue;
					}
					tcol = tex2Dlod(_MainTex, float4(tuv,0,0));
					texid = 0;
					if(tcol.r > 0.5) {
						texid+=1;
					}
					if(tcol.g > 0.5) {
						texid+=2;
					}
					if(tcol.b > 0.5) {
						texid+=4;
					}
					if(cid == 0) {
						tuv = pos.zy;
					} else if(cid == 1) {
						tuv = pos.xz;
					} else {
						tuv = pos.xy;
					}
					if(texid == 1) {
						col = tex2Dlod(_Dirt, float4(tuv, 0,0));
						break;
					} else if(texid == 2) {
						col = tex2Dlod(_Stone, float4(tuv, 0,0));
						break;
					} else if(texid == 3) {
						col = tex2Dlod(_Planks, float4(tuv, 0,0));
						break;
					} else if(texid == 4) {
						if(IGB == 0) {
							col = tex2Dlod(_Glass, float4(tuv, 0,0));
							if(col.a > 0.8) {
								break;
							}
						}
					}
					if(texid == 4) {
						IGB = 1;
					} else {
						IGB = 0;
					}
				}
				float dp = 0;
				float4 tmp;
				if(col.a <= 0.8) {
					if((abs(i.rvp.x) > thick && abs(i.rvp.y) > thick) || (abs(i.rvp.x) > thick && abs(i.rvp.z) > thick) || (abs(i.rvp.y) > thick && abs(i.rvp.z) > thick)) {
						col = fixed4(1,1,1,1);
						tmp = UnityObjectToClipPos(float4(i.rvp.xyz, 1));
						dp = tmp.z/tmp.w;
					}
				} else {
					pos.y*=2.0;
					pos/=16.0;
					pos-=0.5;
					tmp = UnityObjectToClipPos(float4(pos, 1));
					dp = tmp.z/tmp.w;
				}
				o.col = col;
				o.dp = dp;
				return o;
			}
			ENDCG
		}
	}
}
