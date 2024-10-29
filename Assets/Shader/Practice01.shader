// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/BlinnPhong"
{
    Properties {
        _Shininess("Shininess", Range(0, 100)) = 1
        _Falloff("Falloff", Range(0, 8)) = 1
        //_NormalMap("Normal Map", 2D) = "white" {}
        //_NormalScale("Normal Scale", Range(0, 8)) = 1
    }
    SubShader {
        Pass {
            CGPROGRAM
            //#include "UnityCG.cginc" // use this to get standard unity shader features
            #include "UnityStandardBRDF.cginc" // use this to get lighting direction, this includes UnityCG.cginc

            #pragma vertex vert;
            #pragma fragment frag;

            //sampler2D _NormalMap;
            float _Shininess, _Falloff;//, _NormalScale;

            struct appdata {
                float4 objVertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                };
            struct v2f {
                float4 clipPos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 normal : NORMAL;
                };

            v2f vert(appdata input) {
                v2f output;
                output.clipPos = UnityObjectToClipPos(input.objVertex);
                output.uv = input.uv;
                output.worldPos = mul(unity_ObjectToWorld, input.objVertex);
                output.normal = UnityObjectToWorldNormal(input.normal);
                return output;
            }
            float4 frag(v2f input) : SV_TARGET { 
                // V is the direction to the camera
                float3 viewDir = normalize(_WorldSpaceCameraPos - input.worldPos);
    
                // N is the surface normal
                float3 normalDir = normalize(input.normal);
                //normalDir += normalMap;

                // L is the direction to the light
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz); //normalize(_WorldSpaceLightPos0.xyz - input.worldPos);

                // Calculate the halfway vector H for Blinn-Phong specular
                float3 halfwayVector = normalize(lightDir + viewDir);

                // Diffuse calculation
                float diffuse = dot(lightDir, normalDir); //Between -1 and 1
                diffuse *= 0.5f; //Between -0.5 and 0.5
                diffuse += 0.5f; //Between 0 and 1
                diffuse = pow(diffuse, _Falloff);



                // Specular calculation
                float specular = max(dot(normalDir, halfwayVector), 0);
                specular = pow(specular, _Shininess);  // Controls specular highlight sharpness

                // Output as grayscale for specular component only
                float color = diffuse;
                color += specular;

                return float4(color, color, color, 1);
            }

            ENDCG
        }
    }
}
