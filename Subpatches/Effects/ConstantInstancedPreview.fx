//@author: vux
//@help: standard constant shader
//@tags: color
//@credits:

Texture2D texture2d;

//Buffer containing uvs for sampling
StructuredBuffer<float2> uv <string uiname="UV Buffer";>;
StructuredBuffer<float3> pos <string uiname="POS Buffer";>;

float3 rgb = 1;

SamplerState g_samLinear : IMMUTABLE
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Clamp;
	AddressV = Clamp;
};


StructuredBuffer<float4> pData;

//StructuredBuffer<float4> sbColor;

cbuffer cbPerDraw : register( b0 )
{
	float4x4 tW : WORLD;
	float4x4 tWV : WORLD;
	float4x4 tVP : VIEWPROJECTION;
	//int colorcount = 1;
};

float4x4 tWVP: WORLDVIEWPROJECTION;
struct VS_IN
{
	uint i : SV_InstanceID;
	float4 PosO : POSITION;
	//float4 RotO  : ROTATION;
	float2 TexCd : TEXCOORD0;
	
};

struct vs2ps
{
	float4 PosWVP: SV_POSITION;
	float4 Color: TEXCOORD0;
	float2 TexCd: TEXCOORD1;
	float4 Vcol : COLOR2 ;
	
};

vs2ps VS(VS_IN input)
{
	//inititalize all fields of output struct with 0
	vs2ps Out = (vs2ps)0;
	
	//Scale Matrix
	float size = (pData[input.i].r*rgb.x + pData[input.i].g*rgb.y  + pData[input.i].b*rgb.z )/4;
	//float size = (pData[input.i].r )/4;
	float4x4 ScaleMatrix = float4x4(		size,0.0,0.0,0.0,
	0.0,size,0.0,0.0,
	0.0,0.0,size,0.0,
	0.0,0.0,0.0,1.0 );
	
	//float3 p = ppos[input.ii].pos; //particle Pos
	float4 p = float4(pos[input.i],0); //particle Pos
	float4 c = pData[input.i].rgba; //particle colour
	float4 pv = mul(input.PosO,tW); //Transform the model
	pv = mul(pv,ScaleMatrix); //Scale the model
	//pv = mul(pv,RotationMatrix); //Rotate the model
	float4 PosV = pv + p;
	//Out.RotO =
	Out.PosWVP =  mul(PosV, tVP);
	//	Out.Color = sbColor[input.ii % colorcount];
	Out.TexCd = input.TexCd;
	Out.Vcol = c;
	return Out;
}




float4 PS_Tex(vs2ps In): SV_Target
{
	//float4 col = texture2d.Sample( g_samLinear, In.TexCd) ;//* In.Color;
	//col = col*In.Vcol;
	
	float4 col = 0;
	col.r = 1-In.Vcol.r*rgb.x ;
	col.g = 1-In.Vcol.g*rgb.y;
	col.b = 1-In.Vcol.b*rgb.z;
	return col;
}





technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Tex() ) );
	}
}




