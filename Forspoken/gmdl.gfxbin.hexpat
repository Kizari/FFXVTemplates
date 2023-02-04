// ---------------------------
// NOTES:
// * The format used here is called msgpack     https://github.com/msgpack/msgpack/blob/master/spec.md
// * C# implementation of gmdl.gfxbin           https://github.com/Kizari/Flagrum/blob/main/Flagrum.Core/Gfxbin/Gmdl/ModelReader.cs
// * msgpack hexpat exists as well              https://github.com/WerWolv/ImHex-Patterns/blob/master/patterns/msgpack.hexpat
// ---------------------------

#pragma pattern_limit 1310720;

#include <std/io.pat>

enum TypeFormat : u8
{
    PositiveFixIntStart = 0x0,
    PositiveFixIntEnd = 0x7F,
    FixMapStart = 0x80,
    FixMapEnd = 0x8F,
    FixArrayStart = 0x90,
    FixArrayEnd = 0x9F,
    FixStrStart = 0xA0,
    FixStrEnd = 0xBF,
    Nil = 0xC0,
    NeverUsed = 0xC1,
    False = 0xC2,
    True = 0xC3,
    Bin8 = 0xC4,
    Bin16 = 0xC5,
    Bin32 = 0xC6,
    Ext8 = 0xC7,
    Ext16 = 0xC8,
    Ext32 = 0xC9,
    Float32 = 0xCA,
    Float64 = 0xCB,
    Uint8 = 0xCC,
    Uint16 = 0xCD,
    Uint32 = 0xCE,
    Uint64 = 0xCF,
    Int8 = 0xD0,
    Int16 = 0xD1,
    Int32 = 0xD2,
    Int64 = 0xD3,
    FixExt1 = 0xD4,
    FixExt2 = 0xD5,
    FixExt4 = 0xD6,
    FixExt8 = 0xD7,
    FixExt16 = 0xD8,
    Str8 = 0xD9,
    Str16 = 0xDA,
    Str32 = 0xDB,
    Array16 = 0xDC,
    Array32 = 0xDD,
    Map16 = 0xDE,
    Map32 = 0xDF,
    NegativeFixIntStart = 0xE0,
    NegativeFixIntEnd = 0xFF
};

// ---------------------------
// Value Types
// ---------------------------

struct Value
{
    u8 type;
    
    // NOTE: Not all types are implemented yet
    if (type == TypeFormat::Uint64)
    {
        u64 value;
    }
    else if (type == TypeFormat::Uint32 || type == TypeFormat::Array32)
    {
        u32 value;
    }
    else if (type == TypeFormat::Uint16 || type == TypeFormat::Map16 || type == TypeFormat::Array16)
    {
        u16 value;
    }
    else if (type == TypeFormat::Int16)
    {
        s16 value;
    }
    else if (type == TypeFormat::Float32)
    {
        float value;
    }
    else if (type == TypeFormat::Uint8)
    {
        u8 value;
    }
    else
    {
        u8 value @ $ - 1[[transform("default_int")]];
    }
} [[format("format_value")]];

struct String
{
    u8 type;
    
    // There's probably a way to combine this with Value
    if (type < 0xA0 || type > 0xBF)
    {
        u8 length;
    }
    else
    {
        u8 length @ $ - 1[[transform("default_string")]];
    }
    
    char value[length];
} [[format("format_string"), sealed]];

// ---------------------------
// Functions
// ---------------------------

fn default_int(u8 byte)
{
    return byte & 111;
};

fn default_string(u8 byte)
{
    return byte & 95;
};

fn format_value(Value value)
{
    return value.value;
};

fn format_string(String string)
{
    return string.value;
};

// ---------------------------
// Core Structures
// ---------------------------

struct AABB
{
    Value start[3];
    Value end[3];
};

struct Dependency
{
    String hash;
    String uri;
};

struct Bone
{
    String name;
    Value lodIndex;
    Value uniqueIndex;
};

struct Node
{
    Value matrix[12];
    
    if (isFirstNode)
    {
        isFirstNode = false;
    }
    else
    {
        Value unknownFloat;
    }
    
    String name;
    Value unknown;
    Value unknown2;
    Value unknown3;
};

struct VertexElement
{
    Value offset;
    String semantic;
    Value format;
};

struct VertexStream
{
    Value slot;
    Value type;
    Value stride;
    Value startOffset;
    Value vertexElementCount;
    VertexElement vertexElements[vertexElementCount.value];
};

struct SubGeometry
{
    AABB aabb;
    Value startIndex;
    Value primitiveCount;
    Value clusterIndexBitFlag;
    Value drawOrder;
};

struct MeshPart
{
    Value partsId;
    Value startIndex;
    Value indexCount;
};

struct ModelPart
{
    String name;
    Value id;
    String unknown;
    TypeFormat flags;
};

struct Mesh
{
    String name;
    Value vertexLayoutType;
    TypeFormat unknownBool;
    
    AABB aabb;
    TypeFormat isOrientedBB;
    Value orientedBB[12];
    
    Value primitiveType;
    Value faceIndexCount;
    Value faceIndexType;
    Value gpubinIndex;
    Value faceIndexOffset;
    Value faceIndicesSize;
    Value vertexCount;
    
    Value vertexStreamCount;
    VertexStream vertexStreams[vertexStreamCount.value];
    
    Value vertexBufferOffset;
    Value vertexBufferSize;
    
    Value subgeometriesCount;
    SubGeometry subgeometries[subgeometriesCount.value];
    
    // Not sure what this is—looks like an AABB on the test cube
    // Frey doesn't have one though, just an offset with 0 size
    Value unknownCount;
    Value unknownOffset;
    Value unknownSize;
    
    Value materialHash;
    
    Value drawPriorityOffset;
    TypeFormat unknownBool3;
    TypeFormat unknownBool4;
    
    Value lodNear;
    Value lodFar;
    Value lodFade;
    
    Value partsId;
    Value partsCount;
    MeshPart parts[partsCount.value];
    
    TypeFormat unknownBool5;
    Value flags;
    TypeFormat unknownBool6;
    Value breakableBoneIndex;
    Value lowLodShadowCascadeNo;
};

struct MeshObject
{
    if (isFirstMeshObject)
    {
        isFirstMeshObject = false;
    }
    else
    {
        TypeFormat unknownBool;
    }
    
    String name;
    Value clusterCount;
    String clusterName;
    Value meshCount;
    Mesh meshes[meshCount.value];
};

struct AssetHashArray
{
    u8 type [[hidden]];
        
    if (type == TypeFormat::Uint64)
    {
        u64 assetHash;
    }
    else
    {
        $ -= 1;
        break;
    }
} [[inline]];

struct GfxbinHeader
{
    Value version;
    Value dependencyCount;
    Dependency dependencies[dependencyCount.value];
    Value hashCount;
    Value hashes[hashCount.value];
};

struct Gfxbin
{
    AABB aabb;
    
    Value boneCount;
    Bone bones[boneCount.value];
    
    Value nodeCount;
    Node nodes[nodeCount.value];
    
    Value unknownFloat;
    
    Value gpubinCount;
    Value assetHashes[gpubinCount.value];
    
    Value meshObjectCount;
    MeshObject meshObjects[meshObjectCount.value];
    
    TypeFormat unknownBool;
    String name;
    
    Value partsCount;
    ModelPart parts[partsCount.value];
    
    Value someFloat;
    Value someFloat2;
    Value someFloat3;
    Value someFloat4;
    Value someFloat5;
    
    Value gpubinSizeCount;
    Value gpubinSize[gpubinSizeCount.value];
};

// ---------------------------
// Main Template Logic
// ---------------------------

bool isFirstNode = true;
bool isFirstMeshObject = true;
GfxbinHeader header @ 0x00;
Gfxbin gfxbin @ $;


