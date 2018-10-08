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
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#include "AutoLight.cginc"
		sampler2D _MainTex;
		float4 _MainTex_ST;
		float4 _SnowColor;
		float _SnowLevel;
		float _SnowDepth;
		
		struct a2v{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
			
		};

		struct v2f{
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
			float3 worldNormal : TEXCOORD1;
			float3 worldPos : TEXCOORD2;
			SHADOW_COORDS(3)
		};

		


		v2f vert(a2v v) {
			v2f o;

			o.pos = UnityObjectToClipPos(v.vertex);
			o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			TRANSFER_SHADOW(o);
			return o;
		}

		fixed4 frag(v2f i) : SV_Target{

			fixed3 albedo = tex2D(_MainTex, i.uv).rgb;
			fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(i.worldNormal, worldLightDir));
			UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
			fixed3 lightColor = diffuse * atten + ambient;
			fixed4 color = tex2D(_MainTex, i.uv);
			half SnowThreshold = dot(i.worldNormal, float3(0, 1, 0)) - lerp(1, -1, _SnowLevel);
			SnowThreshold = saturate(SnowThreshold / _SnowDepth);
			// SnowThreshold = saturate(_SnowDepth / SnowThreshold);
			color.rgb = _SnowColor.rgb * SnowThreshold  + (1 - SnowThreshold) * color.rgb;

			fixed3 finalColor = lerp(lightColor, color, 1);
			return float4(finalColor, 1);

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
