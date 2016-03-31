Shader "Custom/Dissolve2" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
        _DissolveTex ("Desolve (RGB)", 2D) = "white" {}
        _CutOff("Cut off", Range(0.0, 1.0)) = 0.0
        _Width("Width", Float) = 0.03      
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Transparent" }
		LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha
        #pragma target 3.0
        #pragma debug

        sampler2D _MainTex;
        sampler2D _DissolveTex;
        float _CutOff;
        float _Width;

        struct Input {
            float2 uv_MainTex;
            float2 uv_DissolveTex;         
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;

            fixed a = Luminance(tex2D(_DissolveTex, IN.uv_DissolveTex).xyz);
            if (_CutOff > a) {
                discard;
            }
        }
        ENDCG
	}
	FallBack "Diffuse"
}
