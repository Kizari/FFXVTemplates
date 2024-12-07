#include <std/mem.pat>

// ------------------------------------------------
// Globals
// ------------------------------------------------

u64 start = 0xAA0;
u64 dataOffset;

// ------------------------------------------------
// Functions
// ------------------------------------------------

fn rebase(u64 address)
{
    return start;
};

fn rebase_data(u64 address)
{
    return start + dataOffset;
};

fn rebase_parent(u64 address)
{
    return addressof(parent.parent);
};

fn rebase_grandparent(u64 address)
{
    return addressof(parent.parent.parent.parent);
};

fn format_wstring(ref auto string)
{
    return string.characters;
};

struct WString
{
    char16 characters[while(std::mem::read_unsigned($, 2) != 0x00)];
    char16 nullTerminator[[hidden]];
}[[format("format_wstring"), inline]];

// ------------------------------------------------
// Enumerations
// ------------------------------------------------

enum InfoType : u32
{
    Void = 0x0,
    Struct = 0x1,
    Vector = 0x2,
    Enum = 0x4,
    Int32 = 0x7,
    Uint32 = 0xB,
    String = 0xD,
    kBool = 0xE,
    Float32 = 0xF,
    Blob = 0x12,
    Reference = 0x15
};

// ------------------------------------------------
// Utility Structs
// ------------------------------------------------

struct Unknown {};

struct NullablePtr<T>
{
    u64 address[[no_unique_address]];
    if (address > 0)
    {
        T* pointer : u64[[pointer_base("rebase"), inline]];
    }
    else
    {
        u64 nullPtr;
    }
};

struct UIntPtr
{
    u32* value : u64[[pointer_base("rebase_data")]];
};

// ------------------------------------------------
// Format Structs
// ------------------------------------------------

struct UdsPointer<T>
{
    NullablePtr<T> offset;
    u64 size;
};

struct InfoBase 
{
    InfoType type;
    u64 sizeBits;
    u32 alignmentBits;
    u32 fixid;
    WString* pName : u64[[pointer_base("rebase_parent")]];
    u64 unknown3;
};

struct ReferenceInfo : InfoBase
{
    u64 unknown4;
    u64 unknown5;
    u64 referenceTypeOffset;
};

struct VectorInfo : InfoBase
{
    u64 unknown4;
    u64 unknown5;
    u64 unknown6;
    u64 unknown7;
    u64 itemTypeOffset;
};

struct MemberInfo
{
    u64 typeInfoOffset;
    u64 structOffset;
    WString* name : u64[[pointer_base("rebase_grandparent")]];
};

struct MemberInfoArray
{
    MemberInfo members[parent.memberCount];
}[[inline]];

struct EnumInfo : InfoBase
{
    u32 memberCount;
    u64 memberOffset;
};

struct StructInfo : InfoBase
{
    u32 memberCount;
    MemberInfoArray* membersOffset : u64[[pointer_base("rebase_parent")]];
    u64 baseTypeOffset;
};

struct Type
{
    u32 fixid;
    UIntPtr pType[[no_unique_address, hidden]];
    
    match (pType.value)
    {
        (0x1): StructInfo* typeInfo : u64[[pointer_base("rebase_data")]];
        (0x2): VectorInfo* typeInfo : u64[[pointer_base("rebase_data")]];
        (0x4): EnumInfo* typeInfo : u64[[pointer_base("rebase_data")]];
        (0x15): ReferenceInfo* typeInfo : u64[[pointer_base("rebase_data")]];
        (_): InfoBase* typeInfo : u64[[pointer_base("rebase_data")]];
    }
};

struct TypeInfo
{
    u32 size;
    Type types[size];
};

struct PlatformInfo
{
    WString* pUnknownString : u64[[pointer_base("rebase")]];
    WString* pUnknownString2 : u64[[pointer_base("rebase")]];
}[[single_color]];

struct FileInfo
{
    u32 fixid;
    u64 unknown;
    u32 unknown2;
    WString uri;
}[[single_color]];

struct UdsBinary
{
    char magic[4];
    u64 version;
    
    u64 dataAddress[[no_unique_address]];
    dataOffset = dataAddress;
    
    UdsPointer<Unknown> pData;
    UdsPointer<Unknown> unknownPointer;
    UdsPointer<TypeInfo> pTypeInfo;
    UdsPointer<Unknown> unknownPointer2;
    UdsPointer<Unknown> unknownPointer3;
    UdsPointer<Unknown> typeLocationPointer;
    UdsPointer<PlatformInfo> platformInfoPointer;
    UdsPointer<FileInfo> pFileInfo;
    
    u32 unknown;
    u64 unknown2;
}[[single_color]];

// ------------------------------------------------
// Template Logic
// ------------------------------------------------

UdsBinary root @ start;