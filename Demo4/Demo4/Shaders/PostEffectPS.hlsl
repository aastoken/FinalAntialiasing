#include "PostEffectShared.hlsl"
#include "Utils.hlsl"
#include "Fxaa3_11.h"

#define FXAA_PC 1

static const float2 RenderTargetSize = float2( 1280.0, 720.0 );
static const float2 PixelSize = 1.0 / RenderTargetSize; // Size of a pixel in texcoords (UV coordinates)

Texture2D sceneTexture : register( t0 );
Texture2D depthTexture : register( t1 );
SamplerState samplerState : register( s0 );

float rgb2luma(float3 rgb);

float3 main( OutputVS input ) : SV_TARGET
{
	FxaaFloat2 pos = float2(0.0,0.0);
	FxaaFloat4 fxaaConsolePosPos = float4(0,0,0,0);			//Consola	
	FxaaTex tex = { samplerState, sceneTexture };
	FxaaTex fxaaConsole360TexExpBiasNegOne = { samplerState, sceneTexture };
	FxaaTex fxaaConsole360TexExpBiasNegTwo = { samplerState, sceneTexture };
	FxaaFloat2 fxaaQualityRcpFrame = float2(1.0 / (1280.0), 1.0 / (720.0));
	FxaaFloat4 fxaaConsoleRcpFrameOpt = float4(0, 0, 0, 0);			//Consola	
	FxaaFloat4 fxaaConsoleRcpFrameOpt2 = float4(0, 0, 0, 0);		//Consola	
	FxaaFloat4 fxaaConsole360RcpFrameOpt2 = float4(0, 0, 0, 0);		//Consola	
	FxaaFloat fxaaQualitySubpix = float(1.0);
	FxaaFloat fxaaQualityEdgeThreshold = float(0.063);
	FxaaFloat fxaaQualityEdgeThresholdMin = float(0.0312);
	FxaaFloat fxaaConsoleEdgeSharpness = float(4.0);		//Consola	
	FxaaFloat fxaaConsoleEdgeThreshold = float(0.125);		//Consola	
	FxaaFloat fxaaConsoleEdgeThresholdMin = float(0.05);	//Consola	
	FxaaFloat4 fxaaConsole360ConstDir = float4(1.0, -1.0, 0.25, -0.25);		//Consola	

	float3 colorCenter = sceneTexture.Sample(samplerState, input.texcoord).rgb;
	float3 fragColor;

	// Luma at the current fragment
	float lumaCenter = rgb2luma(colorCenter);

	// Luma at the four direct neighbours of the current fragment.
	float lumaDown = rgb2luma(sceneTexture.Sample(samplerState, input.texcoord + float2(0, -1)).rgb);
	float lumaUp = rgb2luma(sceneTexture.Sample(samplerState, input.texcoord + float2(0, 1)).rgb);
	float lumaLeft = rgb2luma(sceneTexture.Sample(samplerState, input.texcoord + float2(-1, 0)).rgb);
	float lumaRight = rgb2luma(sceneTexture.Sample(samplerState, input.texcoord + float2(1, 0)).rgb);



	// Find the maximum and minimum luma around the current fragment.
	float lumaMin = min(lumaCenter, min(min(lumaDown, lumaUp), min(lumaLeft, lumaRight)));
	float lumaMax = max(lumaCenter, max(max(lumaDown, lumaUp), max(lumaLeft, lumaRight)));

	// Compute the delta.
	float lumaRange = lumaMax - lumaMin;

	// If the luma variation is lower that a threshold (or if we are in a really dark area), we are not on an edge, don't perform any AA.
	if (lumaRange < max(fxaaQualityEdgeThresholdMin, lumaMax*fxaaQualityEdgeThreshold)) {
		fragColor = colorCenter;
		return fragColor;
	//return float3( 0.0, 0.0, 0.0 ); wrong

	}

#if (FXAA)
	return FxaaPixelShader(input.texcoord.xy, fxaaConsolePosPos, tex, fxaaConsole360TexExpBiasNegOne, fxaaConsole360TexExpBiasNegTwo, fxaaQualityRcpFrame, fxaaConsoleRcpFrameOpt, fxaaConsoleRcpFrameOpt2, fxaaConsole360RcpFrameOpt2, fxaaQualitySubpix, fxaaQualityEdgeThreshold, fxaaQualityEdgeThresholdMin, fxaaConsoleEdgeSharpness, fxaaConsoleEdgeThreshold, fxaaConsoleEdgeThresholdMin, fxaaConsole360ConstDir);
#else
	return sceneTexture.Sample(samplerState, input.texcoord).rgb;
#endif
}

float rgb2luma(float3 rgb) {
	return sqrt(dot(rgb, float3(0.299, 0.587, 0.114)));
}