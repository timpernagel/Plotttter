
//This is the buffer from the renderer
//Renderer automatically assigns BACKBUFFER semantic
RWStructuredBuffer<float4> rwbuffer : BACKBUFFER;

int elementCount = 1;

//Texture we want to read from
Texture2D tex <string uiname="Texture";>;

//Buffer containing uvs for sampling
StructuredBuffer<float2> uv <string uiname="UV Buffer";>;
StructuredBuffer< float4x4> sbWorld;
StructuredBuffer<float4> sbColor;

struct VS_IN
{
	uint ii : SV_InstanceID;
	float4 PosO : POSITION;
	float2 TexCd : TEXCOORD0;

};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;	
	float4 Color: TEXCOORD0;
    float2 TexCd: TEXCOORD1;
	
};

SamplerState mySampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};


[numthreads(128, 1, 1)]
void CS( uint3 i : SV_DispatchThreadID)
{ 
	if ((int)i.x > elementCount) {return;}
	
	//Read color and writed to buffer
	rwbuffer[i.x] = tex.SampleLevel(mySampler,uv[i.x],0).xyzw;

}


vs2ps VS(VS_IN input)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
	
	float4x4 w = sbWorld[input.ii];
    Out.PosWVP  = mul(input.PosO,mul(w,tVP));
	Out.Color = sbColor[input.ii % colorcount];
    Out.TexCd = input.TexCd;
    return Out;
}


technique11 Process
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
	}
}







