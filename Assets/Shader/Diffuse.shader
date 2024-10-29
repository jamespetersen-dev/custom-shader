Shader "Custom/Diffuse"
{
    Properties
    {
        _Albedo("Albedo", 2D) = "white" {}
        _Tint ("Tint", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #include "UnityStandardBRDF.cginc"


            #pragma vertex vert
            #pragma fragment frag

            sampler2D _Albedo;
            float4 _Tint;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            struct v2f {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 normal : TEXCOORD2;
            };

            //vertex transformed from object space to world space using model matrix - multiply UNITY_MATRIX_M
            //transformed from world space to view space using view matrix - multiply UNITY_MATRIX_V
            //transformed from view space to clip space using the projection matrix - multiply UNITY_MATRIX_P

            //you can use multiply by UNITY_MATRIX_MVP to go from object to clip space
            //mul(UNITY_MATRIX_MVP, v.vertex); = UnityObjectToClipPos(i.vertex);


            v2f vert(appdata i) {
                v2f o;
                o.position = UnityObjectToClipPos(i.vertex);
                o.uv = i.uv;
                o.worldPos = mul(unity_ObjectToWorld, i.vertex).xyz;
                o.normal = normalize(mul((float3x3)unity_ObjectToWorld, i.normal));
                return o;
            }
            float4 frag(v2f i) : SV_Target {
                float3 lightDir = _WorldSpaceLightPos0.xyz;

                //To get the diffuse. Get the dot product between the normal and the light direction

                float3 dotProduct = dot(lightDir, i.normal);

                return float4(dotProduct * 0.5 + 0.5, 1);
            }




            ENDCG
        }
    }
}
