Shader "Custom/Obsidian"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _Tint("Color Tint", Color) = (1, 1, 1, 1)
        [Gamma] _Metallic("Metallic", Range(0, 1)) = 0
        _Smoothness("Smoothness", Range(0, 1)) = 0.1

    }
    SubShader
    {
        Pass {
            Name "BASE"
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "UnityStandardBRDF.cginc"
            #include "UnityLightingCommon.cginc"

            sampler2D _MainTex;
            float4 _Tint;
            float _Metallic, _Smoothness;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                };
            struct v2f {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                };

            v2f vert(appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag(v2f i) : SV_Target {
                i.normal = normalize(i.normal);
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				
				float3 lightColor = _LightColor0.rgb;
				float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
                float3 specularTint = albedo * _Metallic;
				float oneMinusReflectivity = 1 - _Metallic;
				albedo *= oneMinusReflectivity;
				float3 diffuse = albedo * lightColor * DotClamped(lightDir, i.normal);

                float3 halfVector = normalize(lightDir + viewDir);

				float3 specular = specularTint * lightColor * pow(
					DotClamped(halfVector, i.normal),
					_Smoothness * 100
				);


				return float4(diffuse + specular, 1);
            }


            ENDCG
        }
    }
}
