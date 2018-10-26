Shader "Unlit/RadialBlurShader"
{
	Properties{
		_MainTex("MainTex", 2D) = "white"{}
	}

	SubShader{

		CGINCLUDE
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _RadialBlurTex;
			float _BlurFactor;
			float _LerpValue;
			float4 _ScreenCenter;
			int _Iterations;

			struct a2v{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0; 
			};

			struct v2f_rb{
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};

			v2f_rb vert_radialblur(a2v v){

				v2f_rb o;

				o.pos = UnityObjectToClip(v.vertex);
				o.uv = v.texcoord;

				return o;
			}

			fixed4 frag_radialblur(v2f_rb i) : SV_Target{

				float2 dir = i.uv - _ScreenCenter.xy;
				float4 Color = 0;
				for (int j = 0; j < _Iterations; j++)
				{
					float2 uv = i.uv + _BlurFactor * dir * j;
					Color += tex2D(_MainTex, uv);
				}

				Color /= _Iterations;
				return Color;
			}


			struct v2f{
				float4 pos : SV_POSITION;
				half2 uv0 : TEXCOORD0;
				half2 uv1 : TEXCOORD1;
			};

			v2f vert(a2v v){
				v2f o;

				o.pos = UnityObjectToClip(v.vertex);
				o.uv0 = v.texcoord.xy;
				o.uv1 = v.texcoord.xy;

				return o;
			}


			fixed4 frag(v2f i) : SV_Target{
				float dir = length(i.uv1 - _ScreenCenter.xy);
				float4 mainColor = tex2D(_MainTex, i.uv0);
				float4 blurColor = tex2D(_RadialBlurTex, i.uv1);

				return lerp(mainColor, blurColor, _LerpValue * dir);
			}

		ENDCG

		ZTest Always ZWrite Off Cull Off

		Pass{
			
			CGINCLUDE

			#pragma vertex vert_radialblur
			#pragma fragment frag_radialblur

			ENDCG

		}

		Pass{

			CGINCLUDE

			#pragma vertex vert
			#pragma fragment frag

			ENDCG

		}

	}

	FallBack Off
}
