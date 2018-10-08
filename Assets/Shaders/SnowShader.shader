Shader "Unlit/SnowShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_SnowColor ("Snow Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_SnowLevel ("Snow Level", Range(0, 1)) = 0
		_SnowDepth ("Snow Depth", Range(0, 0.5)) = 0.1
	}
	
	SubShader{

		Tags {"RenderType" = "Opaque"}

		CGINCLUDE
		
		struct a2v{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
		};

		struct v2f{
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
			float3 worldNormal : TEXCOORD1;
		};

		#include "UnityCG.cginc"
		#include "Lighting.cginc"

		sampler2D _MainTex;
		float4 _MainTex_ST;
		float4 _SnowColor;
		float _SnowLevel;
		float _SnowDepth;


		v2f vert(a2v v) {
			v2f o;

			o.pos = UnityObjectToClipPos(v.vertex);
			o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

			return o;
		}

		fixed4 frag(v2f i) : SV_Target{

			fixed4 color = tex2D(_MainTex, i.uv);
			half SnowThreshold = dot(i.worldNormal, float3(0, 1, 0)) - lerp(1, -1, _SnowLevel);
			SnowThreshold = saturate(SnowThreshold / _SnowDepth);
			//SnowThreshold = saturate(_SnowDepth / SnowThreshold);
			color.rgb = _SnowColor.rgb * SnowThreshold  + (1 - SnowThreshold) * color.rgb;

			return color;

		}

		ENDCG


		Pass{

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			ENDCG

		}

	}

	FallBack "Diffuse"
}
