// Thanks to Sai for reversing the gmdl.gfxbin and gpubin format
// ---------------------------
// Also see https://github.com/Kizari/Flagrum/blob/main/Flagrum.Core/Gfxbin/Gmdl/ModelReader.cs
// ---------------------------
// Notes:
// * Booleans with u8 type refer to the values in TypeFormat
// ---------------------------

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
// Functions
// ---------------------------

fn DefaultInt(u8 byte)
{
    return byte & 111;
};

fn DefaultString(u8 byte)
{
    return byte & 95;
};

// ---------------------------
// Value Types
// ---------------------------

struct Value
{
    u8 type;
    
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
        u8 value @ $ - 1[[transform("DefaultInt")]];
    }
};

struct String
{
    u8 type;
    
    if (type < 0xA0 || type > 0xBF)
    {
        u8 length;
    }
    else
    {
        u8 length @ $ - 1[[transform("DefaultString")]];
    }
    
    char value[length];
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
};

struct Node
{
    Value matrix[12];
    String name;
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
    u8 flags; // Boolean
};

struct Mesh
{
    String name;
    u8 unknown;
    
    Value boneIdCount;
    Value boneIds[boneIdCount.value];
    
    Value vertexLayoutType;
    u8 unknownBool;
    AABB aabb;
    u8 isOrientedBB;
    Value orientedBB[12];
    u8 primitiveType;
    
    Value faceIndicesCount;
    u8 faceIndexType;
    Value faceIndexBufferOffset;
    Value faceIndicesBufferSize;
    
    Value vertexCount;
    Value vertexStreamCount;
    VertexStream vertexStreams[vertexStreamCount.value];
    
    Value vertexBufferOffset;
    Value vertexBufferSize;
    
    Value instanceNumber;
    
    Value subgeometriesCount;
    SubGeometry subgeometries[subgeometriesCount.value];
    
    Value materialHash;
    
    Value drawPriorityOffset;
    u8 unknownBool2;
    u8 unknownBool3;
    
    Value lodNear;
    Value lodFar;
    Value lodFade;
    
    u8 unknownBool4;
    u8 unknownBool5;
    
    Value partsId;
    
    Value partsCount;
    MeshPart parts[partsCount.value];
    
    u8 unknownBool6;
    Value flags;
    u8 unknownBool7;
    
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
        u8 unknownBool;
    }
    
    String name;
    Value clusterCount;
    String clusterName;
    Value meshCount;
    Mesh meshes[meshCount.value];
};

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
    u8 instanceNameFormat;
    u8 shaderClassFormat;
    u8 shaderSamplerDescriptionFormat;
    u8 shaderParameterListFormat;
    u8 childClassFormat;
    
    Value boneCount;
    Bone bones[boneCount.value];
    
    Value nodeCount;
    Node nodes[nodeCount.value];
    
    Value assetHash;
    
    Value meshObjectCount;
    MeshObject meshObjects[meshObjectCount.value];
    
    u8 unknownBool;
    String name;
    
    Value partsCount;
    ModelPart parts[partsCount.value];
};

// ---------------------------
// Main Template Logic
// ---------------------------

bool isFirstMeshObject = true;
GfxbinHeader header @ 0x00;
Gfxbin gfxbin @ $;
