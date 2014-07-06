﻿Shader "DeferredShading/DSPointLight" {
	Properties {
		_NormalBuffer ("Normal", 2D) = "white" {}
		_PositionBuffer ("Position", 2D) = "white" {}
		_ColorBuffer ("Color", 2D) = "white" {}
		_GlowBuffer ("Glow", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		Blend One One
		ZTest Always
		ZWrite Off

		CGINCLUDE

		sampler2D _NormalBuffer;
		sampler2D _PositionBuffer;
		sampler2D _ColorBuffer;
		sampler2D _GlowBuffer;
		float4 _LightColor;
		float4 _LightPosition;
		float4 _LightRange; // [0]: range, [1]: 1.0/range
		float4 _ShadowParams; // [0]: 0=disabled, [1]: steps


		struct vs_in
		{
			float4 vertex : POSITION;
		};

		struct ps_in {
			float4 vertex : SV_POSITION;
			float4 screen_pos : TEXCOORD0;
			float4 lightpos_mvp : TEXCOORD1;
		};

		struct ps_out
		{
			float4 color : COLOR0;
		};


		ps_in vert1(vs_in v)
		{
			ps_in o;
			float4 vertex = mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz * (_LightRange.x*2.0), 1.0) );
			o.vertex = vertex;
			o.screen_pos = vertex;
			o.lightpos_mvp = mul(UNITY_MATRIX_MVP, float4(0.0, 0.0, 0.0, 1.0f));
			return o;
		}

		ps_in vert2(vs_in v)
		{
			ps_in o;
			o.vertex = v.vertex;
			o.screen_pos = v.vertex;
			o.lightpos_mvp = mul(UNITY_MATRIX_MVP, float4(0.0, 0.0, 0.0, 1.0f));
			return o;
		}


		ps_out frag (ps_in i)
		{
			float2 coord = (i.screen_pos.xy / i.screen_pos.w + 1.0) * 0.5;

			float4 FragPos4		= tex2D(_PositionBuffer, coord);
			float4 AS		= tex2D(_ColorBuffer, coord);
			float4 NS		= tex2D(_NormalBuffer, coord);
			if(dot(AS.xyz,AS.xyz)==0.0) { discard; }

			float3 FragPos		= FragPos4.xyz;
			float3 LightColor	= _LightColor.rgb;
			float3 LightPos		= _LightPosition.xyz;
			float3 LightDiff	= _LightPosition.xyz - FragPos.xyz;
			float LightDistSq	= dot(LightDiff, LightDiff);
			float LightDist		= sqrt(LightDistSq);
			float3  LightDir	= LightDiff / LightDist;
			float4 LightPositionMVP = i.lightpos_mvp;
			float LightAttenuation	= max(_LightRange.x-LightDist, 0.0)*_LightRange.y;
			if(LightAttenuation==0.0) { discard; }

			if(_ShadowParams[0]!=0.0f) {
				float2 lcoord = (LightPositionMVP.xy/LightPositionMVP.w + 1.0) * 0.5;
				const int Div = (int)_ShadowParams[1];
				float2 D2 = (coord - lcoord) / Div;
				float3 D3 = (FragPos - _LightPosition.xyz) / Div;
				for(int i=0; i<Div; ++i) {
					float4 RayPos = mul(UNITY_MATRIX_MVP, float4(_LightPosition.xyz + (D3*i), 1.0));
					float RayZ = RayPos.z;
					float RayFragZ = tex2D(_PositionBuffer, lcoord + (D2*i)).w;
					if(RayZ > RayFragZ) {
						discard;
					}
				}
			}

			float3 Albedo	= AS.rgb;
			float Shininess	= AS.a;
			float Fresnel	= NS.a;
			float3 Normal	= NS.xyz;
			float3 EyePos	= _WorldSpaceCameraPos.xyz;
			float3 EyeDir	= normalize(EyePos - FragPos);

			float3 h		= normalize(EyeDir + LightDir);
			float nh		= max(dot(Normal, h), 0.0);
			float Specular	= pow(nh, Shininess);
			float Intensity	= max(dot(Normal, LightDir), 0.0);

			float4 Result	= float4(0.0, 0.0, 0.0, 1.0);
			Result.rgb += LightColor * (Albedo * Intensity) * LightAttenuation;
			Result.rgb += LightColor * Specular * LightAttenuation;

			ps_out r = {Result};
			return r;
		}
		ENDCG

		Pass {
			CGPROGRAM
			#pragma vertex vert1
			#pragma fragment frag
			#pragma target 3.0
			#pragma glsl
			ENDCG
		}
		Pass {
			CGPROGRAM
			#pragma vertex vert2
			#pragma fragment frag
			#pragma target 3.0
			#pragma glsl
			ENDCG
		}
	}
}