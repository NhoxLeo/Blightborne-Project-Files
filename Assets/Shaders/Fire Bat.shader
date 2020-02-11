//////////////////////////////////////////////////////////////
/// Shadero Sprite: Sprite Shader Editor - by VETASOFT 2018 //
/// Shader generate with Shadero 1.9.2                      //
/// http://u3d.as/V7t #AssetStore                           //
/// http://www.shadero.com #Docs                            //
//////////////////////////////////////////////////////////////

Shader "Shadero Customs/Fire Bat"
{
Properties
{
[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
_InnerGlowHQ_Intensity_1("_InnerGlowHQ_Intensity_1", Range(1, 16)) = 1
_InnerGlowHQ_Size_1("_InnerGlowHQ_Size_1", Range(1, 16)) = 16
_InnerGlowHQ_Color_1("_InnerGlowHQ_Color_1", COLOR) = (1,0.09577125,0,0.5803922)
_Outline_Size_1("_Outline_Size_1", Range(1, 16)) = 1
_Outline_Color_1("_Outline_Color_1", COLOR) = (1,0.1615937,0,0.8039216)
_Outline_HDR_1("_Outline_HDR_1", Range(0, 2)) = 1
_OperationBlend_Fade_1("_OperationBlend_Fade_1", Range(0, 1)) = 1
_SpriteFade("SpriteFade", Range(0, 1)) = 1.0

// required for UI.Mask
[HideInInspector]_StencilComp("Stencil Comparison", Float) = 8
[HideInInspector]_Stencil("Stencil ID", Float) = 0
[HideInInspector]_StencilOp("Stencil Operation", Float) = 0
[HideInInspector]_StencilWriteMask("Stencil Write Mask", Float) = 255
[HideInInspector]_StencilReadMask("Stencil Read Mask", Float) = 255
[HideInInspector]_ColorMask("Color Mask", Float) = 15

}

SubShader
{

Tags {"Queue" = "Transparent" "IgnoreProjector" = "true" "RenderType" = "Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }
ZWrite Off Blend SrcAlpha OneMinusSrcAlpha Cull Off

// required for UI.Mask
Stencil
{
Ref [_Stencil]
Comp [_StencilComp]
Pass [_StencilOp]
ReadMask [_StencilReadMask]
WriteMask [_StencilWriteMask]
}

Pass
{

CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest
#include "UnityCG.cginc"

struct appdata_t{
float4 vertex   : POSITION;
float4 color    : COLOR;
float2 texcoord : TEXCOORD0;
};

struct v2f
{
float2 texcoord  : TEXCOORD0;
float4 vertex   : SV_POSITION;
float4 color    : COLOR;
};

sampler2D _MainTex;
float _SpriteFade;
float _InnerGlowHQ_Intensity_1;
float _InnerGlowHQ_Size_1;
float4 _InnerGlowHQ_Color_1;
float _Outline_Size_1;
float4 _Outline_Color_1;
float _Outline_HDR_1;
float _OperationBlend_Fade_1;

v2f vert(appdata_t IN)
{
v2f OUT;
OUT.vertex = UnityObjectToClipPos(IN.vertex);
OUT.texcoord = IN.texcoord;
OUT.color = IN.color;
return OUT;
}


float4 OutLine(float2 uv,sampler2D source, float value, float4 color, float HDR)
{

value*=0.01;
float4 mainColor = tex2D(source, uv + float2(-value, value))
+ tex2D(source, uv + float2(value, -value))
+ tex2D(source, uv + float2(value, value))
+ tex2D(source, uv - float2(value, value));

color *= HDR;
mainColor.rgb = color;
float4 addcolor = tex2D(source, uv);
if (mainColor.a > 0.40) { mainColor = color; }
if (addcolor.a > 0.40) { mainColor = addcolor; mainColor.a = addcolor.a; }
return mainColor;
}
float4 OperationBlend(float4 origin, float4 overlay, float blend)
{
float4 o = origin; 
o.a = overlay.a + origin.a * (1 - overlay.a);
o.rgb = (overlay.rgb * overlay.a + origin.rgb * origin.a * (1 - overlay.a)) / (o.a+0.0000001);
o.a = saturate(o.a);
o = lerp(origin, o, blend);
return o;
}
float InnerGlowAlpha(sampler2D source, float2 uv)
{
return (1 - tex2D(source, uv).a);
}
float4 InnerGlow(float2 uv, sampler2D source, float Intensity, float size, float4 color)
{
float step1 = 0.00390625f * size*2;
float step2 = step1 * 2;
float4 result = float4 (0, 0, 0, 0);
float2 texCoord = float2(0, 0);
texCoord = uv + float2(-step2, -step2); result += InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(-step1, -step2); result += 4.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(0, -step2); result += 6.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(step1, -step2); result += 4.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(step2, -step2); result += InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(-step2, -step1); result += 4.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(-step1, -step1); result += 16.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(0, -step1); result += 24.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(step1, -step1); result += 16.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(step2, -step1); result += 4.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(-step2, 0); result += 6.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(-step1, 0); result += 24.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv; result += 36.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(step1, 0); result += 24.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(step2, 0); result += 6.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(-step2, step1); result += 4.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(-step1, step1); result += 16.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(0, step1); result += 24.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(step1, step1); result += 16.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(step2, step1); result += 4.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(-step2, step2); result += InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(-step1, step2); result += 4.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(0, step2); result += 6.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(step1, step2); result += 4.0 * InnerGlowAlpha(source, texCoord);
texCoord = uv + float2(step2, step2); result += InnerGlowAlpha(source, texCoord);
result = result*0.00390625;
result = lerp(tex2D(source,uv),color*Intensity,result*color.a);
result.a = tex2D(source, uv).a;
return saturate(result);
}
float4 frag (v2f i) : COLOR
{
float4 _InnerGlowHQ_1 = InnerGlow(i.texcoord,_MainTex,_InnerGlowHQ_Intensity_1,_InnerGlowHQ_Size_1,_InnerGlowHQ_Color_1);
float4 _Outline_1 = OutLine(i.texcoord,_MainTex,_Outline_Size_1,_Outline_Color_1,_Outline_HDR_1);
float4 OperationBlend_1 = OperationBlend(_Outline_1, _InnerGlowHQ_1, _OperationBlend_Fade_1); 
float4 FinalResult = OperationBlend_1;
FinalResult.rgb *= i.color.rgb;
FinalResult.a = FinalResult.a * _SpriteFade * i.color.a;
FinalResult.rgb *= FinalResult.a;
FinalResult.a = saturate(FinalResult.a);
return FinalResult;
}

ENDCG
}
}
Fallback "Sprites/Default"
}