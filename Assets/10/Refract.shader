Shader "UnityShader/10/Refract"
{
	Properties
	{
		_Color("Main Color", Color) = (1, 1, 1, 1)
		_CubeMap("CubeMap", Cube) = "_Skybox" {}
		_RefractRatio("Refract Ratio", Range(0.1, 1)) = 0.5
		_RefractColor ("Refract Color", Color) = (1, 1, 1, 1)
		_RefractAmount("Refract Amount", Range(0.1, 1)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float3 worldPos : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldRefract : TEXCOOED2;
				float4 vertex : SV_POSITION;
				SHADOW_COORDS(3)
			};

			fixed4 _Color;
			samplerCUBE _CubeMap;
			fixed _RefractRatio;
			fixed4 _RefractColor;
			fixed _RefractAmount;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.worldPos = mul(_Object2World, v.vertex).xyz;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.worldRefract = refract(-normalize(worldViewDir), normalize(o.worldNormal), _RefractRatio);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(i.worldNormal, worldLightDir));
				fixed3 refractColor = texCUBE(_CubeMap, i.worldRefract) * _RefractColor.rgb;
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				fixed3 color = ambient + lerp(diffuse, refractColor, _RefractAmount) * atten;
				return fixed4(color, 1);
			}
			ENDCG
		}
	}
}
