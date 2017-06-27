Shader "UnityShader/10.1.3"
{
	Properties
	{
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_ReflectColor ("Reflection Color", Color) = (1, 1, 1, 1)
		_ReflectAmount ("Reflect Amount", Range(0, 1)) = 1
		_CubeMap("Reflection CubMap", Cube) = "_Skybox" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
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
				float3 worldReflect : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			fixed4 _Color;
			fixed4 _ReflectColor;
			fixed _ReflectAmount;
			samplerCUBE _CubeMap;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.worldPos = mul(_Object2World, v.vertex).xyz;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.worldReflect = reflect(-worldViewDir, o.worldNormal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Color * max(0, dot(worldNormal, worldLightDir));
				fixed3 reflectColor = _ReflectColor * texCUBE(_CubeMap, i.worldReflect);

				//UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				fixed3 col = ambient + lerp(diffuse, reflectColor, _ReflectAmount);
				return fixed4(col.xyz, 1);
			}
			ENDCG
		}
	}
}
