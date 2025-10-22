#include <std/mem.pat>
#include <std/string.pat>
#include <std/io.pat>

// ------------------------------------------------
// Global Variables
// ------------------------------------------------

u32 cursor;
u32 gBitsetBlockCount;

// ------------------------------------------------
// Enumerations
// ------------------------------------------------

enum RawType : u32
{
    Quaternion = 0,
    UncompressedVector3 = 1,
    Vector3_Range0 = 2,
    Vector3_Range1 = 3,
    Vector3_Range2 = 4,
    Vector3_NoScale = 5
};

enum CustomDataType : u32
{
    // 0-3 appear to be for Animation Model
    SkeletalAnimInfo = 0x0,
    PhysicsBoneInfo = 0x1,
    VertexCache_Deprecated = 0x2,

    //BeginSubAssetItemTypes = 0x3,
    LuminousTriggeredAssetItem_Generic = 0x3,

    // 100+ appears to be for Animation Clip, although NoMirrorParts was found to be used in AnimationModel
    //BeginSubAssetContainerTypes = 0x100,
    LuminousAssetTriggerDataCollection = 0x100,
    EndSubAssetContainerTypes = 0x101,
    Obsolete_LuminousIK_ModelData = 0x102,
    BlackTriggerData = 0x103,
    OBSOLETE_Sasquatch_ModelData = 0x104,
    OBSOLETE_Sasquatch_AnimData = 0x105,
    PackedTypeOverrideList = 0x106,
    NoMirrorParts = 0x107,
    AssetRefContainer_SystemInternalUseOnly = 0x10000,
    Obsolete_LuminousWalker_ModelData = 0x10001,
    Obsolete_LuminousWalker_AnimData = 0x10002,
    LuminousMessageTriggerData = 0x10003,
    LuminousAssetTriggerData = 0x10004,

    //BeginBuildCoordinatorDependencyTypes = 0x20000,
    LuminousIkRig = 0x20000,
    LuminousTuningSetPack = 0x20001,
    LuminousLinkAnimScenePath = 0x20002,
    VertexCache = 0x20003,
    EndBuildCoordinatorDependencyTypes = 0x20004,
    NumCustomDataTypes = 0x20005
};

enum TransitionType : u32
{
    None = 0x0,
    Freeze_source_anim = 0x8,
    Freeze_target_anim = 0x10,
    No_AnimFacing_Recompute = 0x20,
    No_AnimOrigin_Recompute = 0x40,

    //Root_Rotation_Types_Start = 0x80,
    Root_No_Source_Rotation = 0x80,
    Root_Use_Target_Rotation = 0x100,
    Root_Lock_Anim_Facing = 0x200,

    //Root_Translation_Types_Start = 0x400,
    Root_No_Source_Translation = 0x400,
    Root_Use_Target_Translation = 0x800,
    Root_MS_Source_Translation = 0x1000,
    Root_WS_Source_Translation = 0x2000,
    Root_Lock_Anim_Origin = 0x4000,

    //CycleMatchBlend_Types_Start = 0x8000,
    MatchFeetCycleEvents = 0x8000,
    MatchFeetCycleEvents_DurationRatio = 0x10000,
    MatchFeetCycleEvents_PH1 = 0x20000,
    MatchFeetCycleEvents_PH2 = 0x40000,

    //CycleMatchBlend_Types_End = 0x40000,
    CycleMatchBlend_Types_All_Bits_Set_Mask = 0x78000,
    SnapshotBlend = 0x80000,
    SnapshotBlendCaptureFromModelSpacePose = 0x100000,
    OverrideTransitionDuration = 0x200000,
    ClearOverrideTransitionFlagsAfterUse = 0x400000,
    IgnoreAnimHookAndContinuePreviousSelection = 0x800000,
    Invalid = 0xFFFFFFFF
};

// ------------------------------------------------
// Type Structures
// ------------------------------------------------

struct Vector4
{
    float x;
    float y;
    float z;
    float w;
};

struct Matrix4x4
{
    Vector4 rows[4];
};

struct BoneName
{
    u32 start = $;
    std::string::NullString name;
    padding[48 - ($ - start)];
};

// ------------------------------------------------
// Format Structures
// ------------------------------------------------

struct Transition
{
    float blendTime;
    float playbackRate;
    float startTime;
    TransitionType flags;
    u32 useCount;
}[[single_color]];

struct SkeletalAnimationInstanceData
{
    u32 unknown;
    float unknown2;
    float unknown3;
    float unknown4;
}[[single_color]];

struct RawData
{
    RawType type;
    u32 entriesCount;
    
    Vector4 values[entriesCount] @ cursor;
    
    cursor += entriesCount * 16; // Move the cursor to the next node's values
}[[single_color]];

struct Dependency
{
    u64 assetId;
    std::string::NullString uri;
    std::mem::AlignTo<8>;
    padding[1]; // Guard byte
}[[single_color]];

struct SkeletalAnimationInformation
{
    u32 boneCount;
    u32 boneCountFullSkeleton;
    u16 boneCountBindOnly;
    u16 afterBonamikStartIndex;
    u16 kdBonesStartIndex;
    u16 dummy;
    s16 childIndexOffsets[boneCount];
    s16 childIndices[boneCount];
    s16 parentIndices[boneCountFullSkeleton];
    s16 childIndexOffsetFullSkeleton[boneCountFullSkeleton];
    s16 childIndicesFullSkeleton[boneCountFullSkeleton];
    u32 boneIds[boneCountFullSkeleton];
    std::mem::AlignTo<16>;
    
    Vector4 modelSpaceBoneRotations[boneCountFullSkeleton];
    Vector4 modelSpaceBoneTranslations[boneCountFullSkeleton];
    Matrix4x4 bindPoseTransformations[boneCountBindOnly];
};

struct CustomDataIndexNode
{
    u64 offset;
    CustomDataType type;
    std::mem::AlignTo<8>;
    
    if (type == CustomDataType::SkeletalAnimInfo)
    {
        SkeletalAnimationInformation data @ (cursor + offset)[[single_color]];
    }
    else if (type == CustomDataType::LuminousIkRig || type == CustomDataType::LuminousTuningSetPack)
    {
        Dependency data @ (cursor + offset)[[single_color]];
    }
    else if (type == CustomDataType::NoMirrorParts)
    {
        u64 bitset[gBitsetBlockCount] @ (cursor + offset)[[single_color]];
    }
    else
    {
        std::error("Unknown custom data type");
    }
}[[single_color]];

struct Channel
{
    u32 entriesCount;
    u32 dataOffset;
    u64 modelTypeSpecificInfoOffset;
    u32 partMaskStartBitIndex;
    padding[4];
    
    u16 indices[entriesCount] @ cursor;
    
    cursor += entriesCount * 2;  // Move the cursor to the next channel's indices
}[[single_color]];

struct Pose
{
    u32 poseSize;
    u32 rawTypesCount;
    u32 rawDataIndexOffset;     // Relative to start of this struct
    u32 bitsetBlockCount;
    gBitsetBlockCount = bitsetBlockCount;
    
    u64 pPosePool;              // Only used at runtime
    u64 pPlaybackCachePool;     // Only used at runtime
    u64 pPartsBitsPool;         // Only used at runtime
    
    u32 postProcessesCount;
    s32 reserved;
    std::mem::AlignTo<120>;
    
    cursor = $ + (24 * 9) + 20; // Just after "totalParts"
    
    Channel channels[9];
    
    u64 boneNamesOffset;
    u32 boneNamesCount;
    u32 partsLayerCount;
    u32 totalParts;
    
    $ = cursor;  // Seek to after the channel indices that were read earlier
    
    u32 partsLayerIds[partsLayerCount][[single_color]];
    u8 partsLayerBitsets[partsLayerCount * bitsetBlockCount * 8][[single_color]];
    std::mem::AlignTo<8>;
    
    // Set the cursor to the beginning of the raw data values
    cursor = $ + (8 * rawTypesCount);
    cursor = std::mem::align_to(16, cursor);
    cursor += 8;
    cursor = std::mem::align_to(16, cursor);
    
    RawData rawData[rawTypesCount][[single_color]];
    std::mem::AlignTo<16>;
    u64 rawDataOffset;
    std::mem::AlignTo<16>;
    
    $ = cursor; // Seek to after the raw data that was read earlier
    
    BoneName boneNames[boneNamesCount];
}[[single_color]];

struct AnimationModel
{
    u32 fileSize;
    float version;
    u32 bindPoseOffset;
    u32 customUserDataCount;
    u64 customUserDataOffset;
    u64 defaultInstanceDataFileBinOffset;
    u64 transitionsOffset;
    u64 defaultTransitionOffset;
    u32 transitionCount;
    u32 instanceDataTypesCount;
    u32 totalInstanceDataSize;
    s32 instanceDataOffsets[instanceDataTypesCount];
    s32 activeInstances;
    std::mem::AlignTo<56>;
    
    Pose pose;
    
    cursor = $;
    CustomDataIndexNode customDataIndex[customUserDataCount];
    
    $ = defaultInstanceDataFileBinOffset;
    
    SkeletalAnimationInstanceData defaultInstanceData;
    Transition transitions[transitionCount];
}[[single_color]];

// ------------------------------------------------
// Template Logic
// ------------------------------------------------

AnimationModel model @ 0x0;