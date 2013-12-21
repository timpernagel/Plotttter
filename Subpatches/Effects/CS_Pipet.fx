
//This is the buffer from the renderer
//Renderer automatically assigns BACKBUFFER semantic

int elementCount = 1;

//Texture we want to read from
Texture2D tex <string uiname="Texture";>;

//Buffer containing uvs for sampling
StructuredBuffer<float2> uv <string uiname="UV Buffer";>;

SamplerState mySampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

RWStructuredBuffer<float4> rwbuffer : BACKBUFFER;

[numthreads(128, 1, 1)]
void CS( uint3 i : SV_DispatchThreadID)
{ 
	if ((int)i.x > elementCount) {return;}
	
	//Read color and writed to buffer
	
	float4 texSampler = tex.SampleLevel(mySampler,uv[i.x],0).xyzw;
	float brightness =  texSampler.x + texSampler.y + texSampler.z;
	//if (brightness > 0.8) {
	rwbuffer[i.x].rgba = tex.SampleLevel(mySampler,uv[i.x],0).xyzw;
//}
}

technique11 Process
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}







