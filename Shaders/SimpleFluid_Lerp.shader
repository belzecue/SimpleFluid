﻿Shader "SimpleFluid/Lerp" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_PrevTex ("Reference", 2D) = "white" {}
        _Emission ("Emission", Range(0, 1)) = 0.1
        [PowerSlider(2.0)]_Dissipation ("Dissipation", Range(0.0001, 10)) = 1
	}
	SubShader {
		Cull Off ZWrite Off ZTest Always

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
            #include "SimpleFluid_Fluidable.cginc"

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            sampler2D _PrevTex;
            float _Emission;
            float _Dissipation;

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			struct v2f {
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v) {
                float2 uvb = v.uv;
                if (_MainTex_TexelSize.y < 0)
                    uvb.y = 1 - uvb.y;

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = float4(v.uv, uvb);
				return o;
			}
			
			float4 frag (v2f i) : SV_Target {
				float4 cimg = tex2D(_MainTex, i.uv.xy);
				float4 cprev = tex2D(_PrevTex, i.uv.zw);

                cprev = float4(cprev.rgb, (1.0 - _Dissipation * unity_DeltaTime.x) * cprev.a);
                return lerp(cprev, cimg, cimg.a * _Emission);
			}
			ENDCG
		}
	}
}
