// --------------------------------------------------
// C# implementation of gmdl.gfxbin - https://github.com/Kizari/Flagrum/blob/main/Flagrum.Core/Gfxbin/Gmtl/MaterialReader.cs
// --------------------------------------------------

#pragma pattern_limit 1310720;

#include <std/io.pat>

// --------------------------------------------------
// MessagePack Implementation
// Slightly altered version of https://github.com/WerWolv/ImHex-Patterns/blob/master/patterns/msgpack.hexpat
// --------------------------------------------------

enum Type : u8 
{
	PositiveFixInt		= 0x00 ... 0x7F,
	FixMap				= 0x80 ... 0x8F,
	FixArray			= 0x90 ... 0x9F,
	FixStr				= 0xA0 ... 0xBF,
	Nil					= 0xC0,
	Unused				= 0xC1,
	False				= 0xC2,
	True				= 0xC3,
	Bin8				= 0xC4,
	Bin16				= 0xC5,
	Bin32				= 0xC6,
	Ext8				= 0xC7,
	Ext16				= 0xC8,
	Ext32				= 0xC9,
	Float32				= 0xCA,
	Float64				= 0xCB,
	Uint8				= 0xCC,
	Uint16				= 0xCD,
	Uint32				= 0xCE,
	Uint64				= 0xCF,
	Int8				= 0xD0,
	Int16				= 0xD1,
	Int32				= 0xD2,
	Int64				= 0xD3,
	FixExt1				= 0xD4,
	FixExt2				= 0xD5,
	FixExt4				= 0xD6,
	FixExt8				= 0xD7,
	FixExt16			= 0xD8,
	Str8				= 0xD9,
	Str16				= 0xDA,
	Str32				= 0xDB,
	Array16				= 0xDC,
	Array32				= 0xDD,
	Map16				= 0xDE,
	Map32				= 0xDF,
	NegativeFixInt		= 0xE0 ... 0xFF
};

using Entry;

fn transform_positive_fixint(Entry entry) 
{
	return entry.value & 0b0111'1111;
};

fn transform_negative_fixint(Entry entry) 
{
	return -(entry.value & 0b0001'1111);
};

fn format_entry(Entry entry)
{
    return entry.value;
};

struct MapEntry 
{
	Entry key, value;
};

struct Entry 
{
	Type type;
	
	if (u8(type) <= 0x7F) {
		$ -= 1;
		u8 value [[format("transform_positive_fixint")]];
	} else if (u8(type) >= Type::NegativeFixInt) {
		$ -= 1;
		u8 value [[format("transform_negative_fixint")]];
	} else if (type == Type::Uint8)
		u8 value;
	else if (type == Type::Uint16)
		u16 value;
	else if (type == Type::Uint32)
		u32 value;
	else if (type == Type::Uint64)
		u64 value;
	else if (type == Type::Int8)
		s8 value;
	else if (type == Type::Int16)
		s16 value;
	else if (type == Type::Int32)
		s32 value;
	else if (type == Type::Int64)
		s64 value;
	else if (type == Type::Float32)
		float value;
	else if (type == Type::Float64)
		double value;
	else if ((u8(type) & 0b1110'0000) == Type::FixStr)
		char value[u8(type) & 0b0001'1111];
	else if (type == Type::Str8) {
		u8 length;
		char value[length];
	} else if (type == Type::Str16) {
		u16 length;
		char value[length];
	} else if (type == Type::Str32) {
		u32 length;
		char value[length];
	} else if (type == Type::Bin8) {
		u8 length;
		u8 value[length];
	} else if (type == Type::Bin16) {
		u16 length;
		u8 value[length];
	} else if (type == Type::Bin32) {
		u32 length;
		u8 value[length];
	} else if ((u8(type) & 0b1111'0000) == Type::FixArray)
		Entry value[u8(type) & 0b0000'1111];
	else if (type == Type::Array16) {
		u16 length;
		Entry value[length];
	} else if (type == Type::Array32) {
		u32 length;
		Entry value[length];
	} else if ((u8(type) & 0b1111'0000) == Type::FixMap)
		MapEntry value[u8(type) & 0b0000'1111];
	else if (type == Type::Map16) {
		u16 length;
		MapEntry value[length];
	} else if (type == Type::Map32) {
		u32 length;
		MapEntry value[length];
	} else if (type == Type::FixExt1) {
		s8 type;
		u8 data;
	} else if (type == Type::FixExt2) {
		s8 type;
		u16 data;
	} else if (type == Type::FixExt4) {
		s8 type;
		u32 data;
	} else if (type == Type::FixExt8) {
		s8 type;
		u64 data;
	} else if (type == Type::FixExt16) {
		s8 type;
		u128 data;
	} else if (type == Type::Ext8) {
		u8 length;
		s8 type;
		u8 data[length];
	} else if (type == Type::Ext16) {
		u16 length;
		s8 type;
		u8 data[length];
	} else if (type == Type::Ext32) {
		u32 length;
		s8 type;
		u8 data[length];
	}
} [[format("format_entry")]];

// --------------------------------------------------
// Core Structures
// --------------------------------------------------

struct Gfxbin
{
    Entry version;
    Entry dependencies;
    Entry hashes;
};

struct Uniform
{
    Entry nameOffset;
    Entry shaderGenNameOffset;
    Entry unknown;
    Entry nameHash;
    Entry shaderGenNameHash;
    Entry unknown2;
    Entry offset;
    Entry size;
    Entry bufferCount;
    Entry flags;
};

struct Buffer
{
    Entry nameOffset;
    Entry shaderGenNameOffset;
    Entry nameHash;
    Entry shaderGenNameHash;
    Entry offset;
    Entry size;
    Entry uniformIndex;
    Entry type;
    Entry flags;
};

struct Texture
{
    Entry resourceFileHash;
    Entry nameOffset;
    Entry shaderGenNameOffset;
    Entry unknown;
    Entry uriOffset;
    Entry nameHash;
    Entry shaderGenNameHash;
    Entry unknown2;
    Entry uriHash;
    Entry flags;
    Entry highTextureStreamingLevels;
};

struct Colour
{
    Entry R;
    Entry G;
    Entry B;
    Entry A;
};

struct Sampler
{
    Entry nameOffset;
    Entry shaderGenNameOffset;
    Entry unknown;
    Entry magFilter;
    Entry minFilter;
    Entry mipFilter;
    Entry wrapS;
    Entry wrapT;
    Entry wrapR;
    Entry mipmapLodBias;
    Entry maxAnsio;
    Entry unknown2;
    Entry unknown3;
    Entry unknown4;
    Colour borderColour;
    Entry minLod;
    Entry maxLod;
    Entry flags;
};

struct ShaderBinary
{
    Entry resourceFileHash;
    Entry uriOffset;
};

struct ShaderProgram
{
    Entry lowKey;
    Entry highKey;
    Entry csBinaryIndex;
    Entry vsBinaryIndex;
    Entry hsBinaryIndex;
    Entry dsBinaryIndex;
    Entry gsBinaryIndex;
    Entry psBinaryIndex;
};

struct Gmtl
{
    Entry nameOffset;
    Entry bufferCount;
    Entry uniformCount;
    Entry textureCount;
    Entry samplerCount;
    Entry totalBufferCount;
    Entry totalUniformCount;
    Entry totalTextureCount;
    Entry totalSamplerCount;
    Entry shaderBinaryCount;
    Entry shaderProgramCount;
    Entry gpubinSize;
    Entry stringBinSize;
    Entry nameHash;
    Entry blendType;
    Entry blendFactor;
    Entry renderStateBits;
    Entry skinVsMaxBoneCount;
    Entry brdfType;
    Entry highTexturePackOffset;
   
    Buffer buffers[totalBufferCount.value];
    Uniform uniforms[totalUniformCount.value];
    Texture textures[totalTextureCount.value];
    Sampler samplers[totalSamplerCount.value];
    ShaderBinary shaderBinaries[shaderBinaryCount.value];
    ShaderProgram shaderPrograms[shaderProgramCount.value];
    Entry gpubin;
    Entry stringbin;
};

// --------------------------------------------------
// Main Template Logic
// --------------------------------------------------

Gfxbin gfxbin @ 0x00;
Gmtl gmtl @ $;



