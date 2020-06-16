#include "PostEffectShared.hlsl"
#include "Utils.hlsl"
#include "Fxaa3_11.h"

#define FXAA 1

Texture2D sceneTexture : register( t0 );
Texture2D depthTexture : register( t1 );
SamplerState samplerState : register( s0 );

float3 main( OutputVS input ) : SV_TARGET
{
	FxaaFloat2 pos = float2(0.0,0.0);
	FxaaFloat4 fxaaConsolePosPos = float4(0,0,0,0);							//Consola	
	FxaaTex tex = { samplerState, sceneTexture };
	FxaaTex fxaaConsole360TexExpBiasNegOne = { samplerState, sceneTexture };
	FxaaTex fxaaConsole360TexExpBiasNegTwo = { samplerState, sceneTexture };
	FxaaFloat2 fxaaQualityRcpFrame = float2(1.0 / (1280.0), 1.0 / (720.0));
	FxaaFloat4 fxaaConsoleRcpFrameOpt = float4(0, 0, 0, 0);					//Consola	
	FxaaFloat4 fxaaConsoleRcpFrameOpt2 = float4(0, 0, 0, 0);				//Consola	
	FxaaFloat4 fxaaConsole360RcpFrameOpt2 = float4(0, 0, 0, 0);				//Consola	
	FxaaFloat fxaaQualitySubpix = float(1.0);
	FxaaFloat fxaaQualityEdgeThreshold = float(0.063);
	FxaaFloat fxaaQualityEdgeThresholdMin = float(0.0312);
	FxaaFloat fxaaConsoleEdgeSharpness = float(4.0);						//Consola	
	FxaaFloat fxaaConsoleEdgeThreshold = float(0.125);						//Consola	
	FxaaFloat fxaaConsoleEdgeThresholdMin = float(0.05);					//Consola	
	FxaaFloat4 fxaaConsole360ConstDir = float4(1.0, -1.0, 0.25, -0.25);		//Consola	

	//This should be the transformation applied to the texture's color
	//But we don't know how to pass these values effectively to the "tex" attribute 
	//tex = ComputeLuma(tex)//????

#if (FXAA)
	return FxaaPixelShader(input.texcoord.xy, fxaaConsolePosPos, tex, fxaaConsole360TexExpBiasNegOne, fxaaConsole360TexExpBiasNegTwo, fxaaQualityRcpFrame, fxaaConsoleRcpFrameOpt, fxaaConsoleRcpFrameOpt2, fxaaConsole360RcpFrameOpt2, fxaaQualitySubpix, fxaaQualityEdgeThreshold, fxaaQualityEdgeThresholdMin, fxaaConsoleEdgeSharpness, fxaaConsoleEdgeThreshold, fxaaConsoleEdgeThresholdMin, fxaaConsole360ConstDir);
#else
	return sceneTexture.Sample(samplerState, input.texcoord).rgb;
#endif
}

//Going with the type "FxaaTex" for this function as the Fxaa3_11's definition of the "Tex" attribute seems to hint at the existence of r,g,b,a attributes in the FxaaTex type, although it clearly doesn't work.
/*FxaaTex ComputeLuma(FxaaTex color)
{
	color.rgb = ToneMap(color.rgb);  // linear color output
	color.rgb = sqrt(color.rgb);     // gamma 2.0 color output
	color.a = dot(color.rgb, FxaaFloat3(0.299, 0.587, 0.114)); // compute luma
	return color	
}*/