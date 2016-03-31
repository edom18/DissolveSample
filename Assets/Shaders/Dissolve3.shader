Shader "Custom/Dissolve3" {
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

        
    // ------------------------------------------------------------
    // Surface shader code generated out of a CGPROGRAM block:
    ZWrite Off ColorMask RGB
    

    // ---- forward rendering base pass:
    Pass {




        Name "FORWARD"
        Tags { "LightMode" = "ForwardBase" }
        Blend One OneMinusSrcAlpha

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma target 3.0
#pragma debug
#pragma multi_compile_fog
#pragma multi_compile_fwdbasealpha noshadow
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
// Surface shader code generated based on:
// writes to per-pixel normal: no
// writes to emission: no
// needs world space reflection vector: no
// needs world space normal vector: no
// needs screen space position: no
// needs world space position: no
// needs view direction: no
// needs world space view direction: no
// needs world space position for lighting: YES
// needs world space view direction for lighting: YES
// needs world space view direction for lightmaps: no
// needs vertex color: no
// needs VFACE: no
// passes tangent-to-world matrix to pixel shader: no
// reads from normal: no
// 2 texcoords actually used
//   float2 _MainTex
//   float2 _DissolveTex
#define UNITY_PASS_FORWARDBASE
#define _ALPHAPREMULTIPLY_ON 1
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal

// Original surface shader snippet:
#line 13 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

        //#pragma surface surf Standard fullforwardshadows alpha
        //#pragma target 3.0
        //#pragma debug

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
        

// vertex-to-fragment interpolation data
// no lightmaps:
#ifdef LIGHTMAP_OFF
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0; // _MainTex _DissolveTex
  half3 worldNormal : TEXCOORD1;
  float3 worldPos : TEXCOORD2;
  #if UNITY_SHOULD_SAMPLE_SH
  half3 sh : TEXCOORD3; // SH
  #endif
  UNITY_FOG_COORDS(4)
  #if SHADER_TARGET >= 30
  float4 lmap : TEXCOORD5;
  #endif
};
#endif
// with lightmaps:
#ifndef LIGHTMAP_OFF
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0; // _MainTex _DissolveTex
  half3 worldNormal : TEXCOORD1;
  float3 worldPos : TEXCOORD2;
  float4 lmap : TEXCOORD3;
  UNITY_FOG_COORDS(4)
  #ifdef DIRLIGHTMAP_COMBINED
  fixed3 tSpace0 : TEXCOORD5;
  fixed3 tSpace1 : TEXCOORD6;
  fixed3 tSpace2 : TEXCOORD7;
  #endif
};
#endif
float4 _MainTex_ST;
float4 _DissolveTex_ST;

// vertex shader
v2f_surf vert_surf (appdata_full v) {
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
  o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _DissolveTex);
  float3 worldPos = mul(_Object2World, v.vertex).xyz;
  fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
  #if !defined(LIGHTMAP_OFF) && defined(DIRLIGHTMAP_COMBINED)
  fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
  fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
  fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
  #endif
  #if !defined(LIGHTMAP_OFF) && defined(DIRLIGHTMAP_COMBINED)
  o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
  o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
  o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
  #endif
  o.worldPos = worldPos;
  o.worldNormal = worldNormal;
  #ifndef DYNAMICLIGHTMAP_OFF
  o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  #endif
  #ifndef LIGHTMAP_OFF
  o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
  #endif

  // SH/ambient and vertex lights
  #ifdef LIGHTMAP_OFF
    #if UNITY_SHOULD_SAMPLE_SH
      o.sh = 0;
      // Approximated illumination from non-important point lights
      #ifdef VERTEXLIGHT_ON
        o.sh += Shade4PointLights (
          unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
          unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
          unity_4LightAtten0, worldPos, worldNormal);
      #endif
      o.sh = ShadeSHPerVertex (worldNormal, o.sh);
    #endif
  #endif // LIGHTMAP_OFF

  UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
  return o;
}

// fragment shader
fixed4 frag_surf (v2f_surf IN) : SV_Target {
  // prepare and unpack data
  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
  surfIN.uv_MainTex.x = 1.0;
  surfIN.uv_DissolveTex.x = 1.0;
  surfIN.uv_MainTex = IN.pack0.xy;
  surfIN.uv_DissolveTex = IN.pack0.zw;
  float3 worldPos = IN.worldPos;
  #ifndef USING_DIRECTIONAL_LIGHT
    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
  #else
    fixed3 lightDir = _WorldSpaceLightPos0.xyz;
  #endif
  fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutputStandard o = (SurfaceOutputStandard)0;
  #else
  SurfaceOutputStandard o;
  #endif
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Alpha = 0.0;
  o.Occlusion = 1.0;
  fixed3 normalWorldVertex = fixed3(0,0,1);
  o.Normal = IN.worldNormal;
  normalWorldVertex = IN.worldNormal;

  // call surface function
  surf (surfIN, o);

  // compute lighting & shadowing factor
  UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
  fixed4 c = 0;

  // Setup lighting environment
  UnityGI gi;
  UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
  gi.indirect.diffuse = 0;
  gi.indirect.specular = 0;
  #if !defined(LIGHTMAP_ON)
      gi.light.color = _LightColor0.rgb;
      gi.light.dir = lightDir;
      gi.light.ndotl = LambertTerm (o.Normal, gi.light.dir);
  #endif
  // Call GI (lightmaps/SH/reflections) lighting function
  UnityGIInput giInput;
  UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
  giInput.light = gi.light;
  giInput.worldPos = worldPos;
  giInput.worldViewDir = worldViewDir;
  giInput.atten = atten;
  #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
    giInput.lightmapUV = IN.lmap;
  #else
    giInput.lightmapUV = 0.0;
  #endif
  #if UNITY_SHOULD_SAMPLE_SH
    giInput.ambient = IN.sh;
  #else
    giInput.ambient.rgb = 0.0;
  #endif
  giInput.probeHDR[0] = unity_SpecCube0_HDR;
  giInput.probeHDR[1] = unity_SpecCube1_HDR;
  #if UNITY_SPECCUBE_BLENDING || UNITY_SPECCUBE_BOX_PROJECTION
    giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
  #endif
  #if UNITY_SPECCUBE_BOX_PROJECTION
    giInput.boxMax[0] = unity_SpecCube0_BoxMax;
    giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
    giInput.boxMax[1] = unity_SpecCube1_BoxMax;
    giInput.boxMin[1] = unity_SpecCube1_BoxMin;
    giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
  #endif
  LightingStandard_GI(o, giInput, gi);

  // realtime lighting: call lighting function
  c += LightingStandard (o, worldViewDir, gi);
  UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
  return c;
}

ENDCG

}

// 縁を描く
    Pass {
        Name "FORWARD"
        Tags { "LightMode" = "ForwardBase" }
        Blend One One

CGPROGRAM
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma target 3.0
#pragma debug
#pragma multi_compile_fog
#pragma multi_compile_fwdbasealpha noshadow
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#define UNITY_PASS_FORWARDBASE
#define _ALPHAPREMULTIPLY_ON 1
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal

#line 13 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

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
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;

            fixed a = Luminance(tex2D(_DissolveTex, IN.uv_DissolveTex).xyz);
            fixed w = _Width;
            fixed b = smoothstep(_CutOff - w, _CutOff, a) - smoothstep(_CutOff, _CutOff + w, a);
            o.Albedo = fixed3(0.0, b, 0.0);
        }
        

#ifdef LIGHTMAP_OFF
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0; // _MainTex _DissolveTex
  half3 worldNormal : TEXCOORD1;
  float3 worldPos : TEXCOORD2;
  #if UNITY_SHOULD_SAMPLE_SH
  half3 sh : TEXCOORD3; // SH
  #endif
  UNITY_FOG_COORDS(4)
  #if SHADER_TARGET >= 30
  float4 lmap : TEXCOORD5;
  #endif
};
#endif
// with lightmaps:
#ifndef LIGHTMAP_OFF
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0; // _MainTex _DissolveTex
  half3 worldNormal : TEXCOORD1;
  float3 worldPos : TEXCOORD2;
  float4 lmap : TEXCOORD3;
  UNITY_FOG_COORDS(4)
  #ifdef DIRLIGHTMAP_COMBINED
  fixed3 tSpace0 : TEXCOORD5;
  fixed3 tSpace1 : TEXCOORD6;
  fixed3 tSpace2 : TEXCOORD7;
  #endif
};
#endif
float4 _MainTex_ST;
float4 _DissolveTex_ST;

// vertex shader
v2f_surf vert_surf (appdata_full v) {
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
  o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _DissolveTex);
  float3 worldPos = mul(_Object2World, v.vertex).xyz;
  fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
  #if !defined(LIGHTMAP_OFF) && defined(DIRLIGHTMAP_COMBINED)
  fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
  fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
  fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
  #endif
  #if !defined(LIGHTMAP_OFF) && defined(DIRLIGHTMAP_COMBINED)
  o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
  o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
  o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
  #endif
  o.worldPos = worldPos;
  o.worldNormal = worldNormal;
  #ifndef DYNAMICLIGHTMAP_OFF
  o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  #endif
  #ifndef LIGHTMAP_OFF
  o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
  #endif

  // SH/ambient and vertex lights
  #ifdef LIGHTMAP_OFF
    #if UNITY_SHOULD_SAMPLE_SH
      o.sh = 0;
      // Approximated illumination from non-important point lights
      #ifdef VERTEXLIGHT_ON
        o.sh += Shade4PointLights (
          unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
          unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
          unity_4LightAtten0, worldPos, worldNormal);
      #endif
      o.sh = ShadeSHPerVertex (worldNormal, o.sh);
    #endif
  #endif // LIGHTMAP_OFF

  UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
  return o;
}

// fragment shader
fixed4 frag_surf (v2f_surf IN) : SV_Target {
  // prepare and unpack data
  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
  surfIN.uv_MainTex.x = 1.0;
  surfIN.uv_DissolveTex.x = 1.0;
  surfIN.uv_MainTex = IN.pack0.xy;
  surfIN.uv_DissolveTex = IN.pack0.zw;
  float3 worldPos = IN.worldPos;
  #ifndef USING_DIRECTIONAL_LIGHT
    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
  #else
    fixed3 lightDir = _WorldSpaceLightPos0.xyz;
  #endif
  fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutputStandard o = (SurfaceOutputStandard)0;
  #else
  SurfaceOutputStandard o;
  #endif
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Alpha = 0.0;
  o.Occlusion = 1.0;
  fixed3 normalWorldVertex = fixed3(0,0,1);
  o.Normal = IN.worldNormal;
  normalWorldVertex = IN.worldNormal;

  // call surface function
  surf (surfIN, o);

  // compute lighting & shadowing factor
  UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
  fixed4 c = 0;

  // Setup lighting environment
  UnityGI gi;
  UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
  gi.indirect.diffuse = 0;
  gi.indirect.specular = 0;
  #if !defined(LIGHTMAP_ON)
      gi.light.color = _LightColor0.rgb;
      gi.light.dir = lightDir;
      gi.light.ndotl = LambertTerm (o.Normal, gi.light.dir);
  #endif
  // Call GI (lightmaps/SH/reflections) lighting function
  UnityGIInput giInput;
  UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
  giInput.light = gi.light;
  giInput.worldPos = worldPos;
  giInput.worldViewDir = worldViewDir;
  giInput.atten = atten;
  #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
    giInput.lightmapUV = IN.lmap;
  #else
    giInput.lightmapUV = 0.0;
  #endif
  #if UNITY_SHOULD_SAMPLE_SH
    giInput.ambient = IN.sh;
  #else
    giInput.ambient.rgb = 0.0;
  #endif
  giInput.probeHDR[0] = unity_SpecCube0_HDR;
  giInput.probeHDR[1] = unity_SpecCube1_HDR;
  #if UNITY_SPECCUBE_BLENDING || UNITY_SPECCUBE_BOX_PROJECTION
    giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
  #endif
  #if UNITY_SPECCUBE_BOX_PROJECTION
    giInput.boxMax[0] = unity_SpecCube0_BoxMax;
    giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
    giInput.boxMax[1] = unity_SpecCube1_BoxMax;
    giInput.boxMin[1] = unity_SpecCube1_BoxMin;
    giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
  #endif
  LightingStandard_GI(o, giInput, gi);

  // realtime lighting: call lighting function
  c += LightingStandard (o, worldViewDir, gi);
  UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
  return c;
}

ENDCG

}






    // ---- forward rendering additive lights pass:
    Pass {
        Name "FORWARD"
        Tags { "LightMode" = "ForwardAdd" }
        ZWrite Off Blend One One
        Blend One One

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma target 3.0
#pragma debug
#pragma multi_compile_fog
#pragma multi_compile_fwdadd_fullshadows noshadow
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
// Surface shader code generated based on:
// writes to per-pixel normal: no
// writes to emission: no
// needs world space reflection vector: no
// needs world space normal vector: no
// needs screen space position: no
// needs world space position: no
// needs view direction: no
// needs world space view direction: no
// needs world space position for lighting: YES
// needs world space view direction for lighting: YES
// needs world space view direction for lightmaps: no
// needs vertex color: no
// needs VFACE: no
// passes tangent-to-world matrix to pixel shader: no
// reads from normal: no
// 2 texcoords actually used
//   float2 _MainTex
//   float2 _DissolveTex
#define UNITY_PASS_FORWARDADD
#define _ALPHAPREMULTIPLY_ON 1
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal

// Original surface shader snippet:
#line 13 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

        //#pragma surface surf Standard fullforwardshadows alpha
        //#pragma target 3.0
        //#pragma debug

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
        

// vertex-to-fragment interpolation data
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0; // _MainTex _DissolveTex
  half3 worldNormal : TEXCOORD1;
  float3 worldPos : TEXCOORD2;
  UNITY_FOG_COORDS(3)
};
float4 _MainTex_ST;
float4 _DissolveTex_ST;

// vertex shader
v2f_surf vert_surf (appdata_full v) {
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
  o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _DissolveTex);
  float3 worldPos = mul(_Object2World, v.vertex).xyz;
  fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
  o.worldPos = worldPos;
  o.worldNormal = worldNormal;

  UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
  return o;
}

// fragment shader
fixed4 frag_surf (v2f_surf IN) : SV_Target {
  // prepare and unpack data
  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
  surfIN.uv_MainTex.x = 1.0;
  surfIN.uv_DissolveTex.x = 1.0;
  surfIN.uv_MainTex = IN.pack0.xy;
  surfIN.uv_DissolveTex = IN.pack0.zw;
  float3 worldPos = IN.worldPos;
  #ifndef USING_DIRECTIONAL_LIGHT
    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
  #else
    fixed3 lightDir = _WorldSpaceLightPos0.xyz;
  #endif
  fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutputStandard o = (SurfaceOutputStandard)0;
  #else
  SurfaceOutputStandard o;
  #endif
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Alpha = 0.0;
  o.Occlusion = 1.0;
  fixed3 normalWorldVertex = fixed3(0,0,1);
  o.Normal = IN.worldNormal;
  normalWorldVertex = IN.worldNormal;

  // call surface function
  surf (surfIN, o);
  UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
  fixed4 c = 0;

  // Setup lighting environment
  UnityGI gi;
  UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
  gi.indirect.diffuse = 0;
  gi.indirect.specular = 0;
  #if !defined(LIGHTMAP_ON)
      gi.light.color = _LightColor0.rgb;
      gi.light.dir = lightDir;
      gi.light.ndotl = LambertTerm (o.Normal, gi.light.dir);
  #endif
  gi.light.color *= atten;
  c += LightingStandard (o, worldViewDir, gi);
  UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
  return c;
}

ENDCG

}

    // ---- meta information extraction pass:
    Pass {
        Name "Meta"
        Tags { "LightMode" = "Meta" }
        Cull Off

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma target 3.0
#pragma debug
#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2 noshadow
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
// Surface shader code generated based on:
// writes to per-pixel normal: no
// writes to emission: no
// needs world space reflection vector: no
// needs world space normal vector: no
// needs screen space position: no
// needs world space position: no
// needs view direction: no
// needs world space view direction: no
// needs world space position for lighting: YES
// needs world space view direction for lighting: YES
// needs world space view direction for lightmaps: no
// needs vertex color: no
// needs VFACE: no
// passes tangent-to-world matrix to pixel shader: no
// reads from normal: no
// 2 texcoords actually used
//   float2 _MainTex
//   float2 _DissolveTex
#define UNITY_PASS_META
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityPBSLighting.cginc"

#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal

// Original surface shader snippet:
#line 13 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

        //#pragma surface surf Standard fullforwardshadows alpha
        //#pragma target 3.0
        //#pragma debug

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
        
#include "UnityMetaPass.cginc"

// vertex-to-fragment interpolation data
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0; // _MainTex _DissolveTex
  float3 worldPos : TEXCOORD1;
};
float4 _MainTex_ST;
float4 _DissolveTex_ST;

// vertex shader
v2f_surf vert_surf (appdata_full v) {
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
  o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _DissolveTex);
  float3 worldPos = mul(_Object2World, v.vertex).xyz;
  fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
  o.worldPos = worldPos;
  return o;
}

// fragment shader
fixed4 frag_surf (v2f_surf IN) : SV_Target {
  // prepare and unpack data
  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
  surfIN.uv_MainTex.x = 1.0;
  surfIN.uv_DissolveTex.x = 1.0;
  surfIN.uv_MainTex = IN.pack0.xy;
  surfIN.uv_DissolveTex = IN.pack0.zw;
  float3 worldPos = IN.worldPos;
  #ifndef USING_DIRECTIONAL_LIGHT
    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
  #else
    fixed3 lightDir = _WorldSpaceLightPos0.xyz;
  #endif
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutputStandard o = (SurfaceOutputStandard)0;
  #else
  SurfaceOutputStandard o;
  #endif
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Alpha = 0.0;
  o.Occlusion = 1.0;
  fixed3 normalWorldVertex = fixed3(0,0,1);

  // call surface function
  surf (surfIN, o);
  UnityMetaInput metaIN;
  UNITY_INITIALIZE_OUTPUT(UnityMetaInput, metaIN);
  metaIN.Albedo = o.Albedo;
  metaIN.Emission = o.Emission;
  return UnityMetaFragment(metaIN);
}

ENDCG

}

    // ---- end of surface shader generated code

#LINE 46

    }
    FallBack "Diffuse"
}
