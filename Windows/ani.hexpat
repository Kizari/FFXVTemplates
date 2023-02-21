#include <std/math.pat>

fn align(u32 blockSize)
{
    u32 offset = $;
    u32 alignmentPaddingSize = blockSize + blockSize * (offset / blockSize) - offset;
    if (alignmentPaddingSize == blockSize)
    {
        return 0;
    }
    
    return alignmentPaddingSize;
};

// ------------------------------------------------
// Enumerations
// ------------------------------------------------

enum LmETriggerTrackType : u16
{
    eTriggerTrackType_LocomotionFeetEventTrack  = 0x0,
    eTriggerTrackType_ExampleType_RangeBegin  = 0x0B,
    eTriggerTrackType_ExampleType_RangeEnd  = 0x14,
    eTriggerTrackType_LuminousMessageTriggerTrack_RangeBegin  = 0x21,
    eTriggerTrackType_LuminousMessageTriggerTrack_RangeEnd  = 0x100,
    eTriggerTrackType_LuminousAssetTriggerTrack_RangeBegin  = 0x1001,
    eTriggerTrackType_LuminousAssetTriggerTrack_Anonymous_RangeBegin  = 0x1001,
    eTriggerTrackType_LuminousAssetTriggerTrack_Anonymous_RangeEnd  = 0x1100,
    eTriggerTrackType_LuminousAssetTriggerTrack_InModel_RangeBegin  = 0x1101,
    eTriggerTrackType_LuminousAssetTriggerTrack_InModel_RangeEnd  = 0x1200,
    eTriggerTrackType_LuminousAssetTriggerTrack_ModelDrawable_RangeBegin  = 0x1201,
    eTriggerTrackType_LuminousAssetTriggerTrack_ModelDrawable_RangeEnd  = 0x1300,
    eTriggerTrackType_LuminousAssetTriggerTrack_Collision_RangeBegin  = 0x1301,
    eTriggerTrackType_LuminousAssetTriggerTrack_Collision_RangeEnd  = 0x1400,
    eTriggerTrackType_LuminousAssetTriggerTrack_VFX_RangeBegin  = 0x1401,
    eTriggerTrackType_LuminousAssetTriggerTrack_VFX_RangeEnd  = 0x1500,
    eTriggerTrackType_LuminousAssetTriggerTrack_Sound_RangeBegin  = 0x1501,
    eTriggerTrackType_LuminousAssetTriggerTrack_Sound_RangeEnd  = 0x1600,
    eTriggerTrackType_LuminousAssetTriggerTrack_Light_RangeBegin  = 0x1601,
    eTriggerTrackType_LuminousAssetTriggerTrack_Light_RangeEnd  = 0x1700,
    eTriggerTrackType_LuminousAssetTriggerTrack_Camera_RangeBegin  = 0x1701,
    eTriggerTrackType_LuminousAssetTriggerTrack_Camera_RangeEnd  = 0x1800,
    eTriggerTrackType_LuminousAssetTriggerTrack_Scaleform_RangeBegin  = 0x1801,
    eTriggerTrackType_LuminousAssetTriggerTrack_Scaleform_RangeEnd  = 0x1900,
    eTriggerTrackType_RequireTrackTypeMatchForRangeEventMatch_RangeEnd  = 0x1FFF,
    eTriggerTrackType_BlackAssetTriggerTrack_General_RangeBegin  = 0x2001,
    eTriggerTrackType_BlackAssetTriggerTrack_General_RangeEnd  = 0x2100,
    eTriggerTrackType_BlackAssetTriggerTrack_VFX_RangeBegin  = 0x2101,
    eTriggerTrackType_BlackAssetTriggerTrack_VFX_RangeEnd  = 0x2200,
    eTriggerTrackType_BlackAssetTriggerTrack_Sound_RangeBegin  = 0x2201,
    eTriggerTrackType_BlackAssetTriggerTrack_Sound_RangeEnd  = 0x2300,
    eTriggerTrackType_BlackAssetTriggerTrack_Combat_RangeBegin  = 0x2301,
    eTriggerTrackType_BlackAssetTriggerTrack_Combat_RangeEnd  = 0x2400,
    eTriggerTrackType_BlackAssetTriggerTrack_Facial_RangeBegin  = 0x2401,
    eTriggerTrackType_BlackAssetTriggerTrack_Facial_RangeEnd  = 0x2500,
    eTriggerTrackType_AnyTypeEnumIdx  = 0x0FFFE,
    eTriggerTrackType_Unknown  = 0x0FFFF,
};

enum LmEAnimCustomDataType : u32
{
    eCustomUserDataType_SkeletalAnimInfo  = 0x0,
    eCustomUserDataType_PhysicsBoneInfo  = 0x1,
    eCustomUserDataType_VertexCache_Deprecated  = 0x2,
    eCustomUserDataType_BeginSubAssetItemTypes  = 0x3,
    eCustomUserDataType_LuminousTriggeredAssetItem_Generic  = 0x3,
    eCustomUserDataType_BeginSubAssetContainerTypes  = 0x100,
    eCustomUserDataType_LuminousAssetTriggerDataCollection  = 0x100,
    eCustomUserDataType_EndSubAssetContainerTypes  = 0x101,
    eCustomUserDataType_Obsolete_LuminousIK_ModelData  = 0x102,
    eCustomUserDataType_BlackTriggerData  = 0x103,
    eCustomUserDataType_OBSOLETE_Sasquatch_ModelData  = 0x104,
    eCustomUserDataType_OBSOLETE_Sasquatch_AnimData  = 0x105,
    eCustomUserDataType_PackedTypeOverrideList  = 0x106,
    eCustomUserDataType_NoMirrorParts  = 0x107,
    eCustomUserDataType_AssetRefContainer_SystemInternalUseOnly  = 0x10000,
    eCustomUserDataType_Obsolete_LuminousWalker_ModelData  = 0x10001,
    eCustomUserDataType_Obsolete_LuminousWalker_AnimData  = 0x10002,
    eCustomUserDataType_LuminousMessageTriggerData  = 0x10003,
    eCustomUserDataType_LuminousAssetTriggerData  = 0x10004,
    eCustomUserDataType_BeginBuildCoordinatorDependencyTypes  = 0x20000,
    eCustomUserDataType_LuminousIkRig  = 0x20000,
    eCustomUserDataType_LuminousTuningSetPack  = 0x20001,
    eCustomUserDataType_LuminousLinkAnimScenePath  = 0x20002,
    eCustomUserDataType_VertexCache  = 0x20003,
    eCustomUserDataType_EndBuildCoordinatorDependencyTypes  = 0x20004,
    eCustomUserDataType_NumCustomDataTypes  = 0x20005
};

enum LmEAnimPropertyBits : u32
{
    eAnimPropertyLooping  = 1,
    eAnimAbsoluteMode  = 2
};

enum LmEPackedKeyType : u32
{
    ePackedKeyType_Quat_40  = 0,
    ePackedKeyType_Quat_48  = 1,
    ePackedKeyType_Quat_48_Deprecated  = 2,
    ePackedKeyType_Quat_128  = 3,
    ePackedKeyType_Vector3_48  = 4    ,      
    ePackedKeyType_Vector3_48_NoScale  = 5  ,
    ePackedKeyType_Vector3_128  = 6      ,   
    ePackedKeyType_Vector3_128_NoScale  = 7,
    ePackedKeyType_Num_PK_Types  = 8
};

// ------------------------------------------------
// Structures
// ------------------------------------------------

struct PackedKey
{
    u16 data[3];
};

struct LmSSingleAnimFrame
{
    // [0] - used to help calculate the number of keys in the frame
    // [1] - used to help calculate the number of keys in the frame
    // [2] - The number of timeKeyArrayStepModifiers
    u8 numKeys[3];

    if (numKeys[0] == 0 && numKeys[1] == 0)
    {
        // Empty frames are represented as two zero bytes
        // Go back one and skip the rest of the frame
        $ -= 1;
    }
    else
    {
        // These seem to affect how the animation steps through the currentKeyTimeBytes array
        u8 timeKeyArrayStepModifiers[numKeys[2]];

        // It looks like these have to do with the timing of each key?
        u8 currentKeyTimeBytes[(((numKeys[1] >> 4) + 16 * numKeys[0]) & 1) + (((numKeys[1] >> 4) + 16 * numKeys[0]) >> 1)];
        
        padding[align(2)];
        PackedKey packedKeys[(numKeys[1] >> 4) + 16 * numKeys[0]];
    }
};

struct LmSAnimFrameChunkInfo
{
    u16 lastFrameStartOffsets[16];
};

struct LmSAnimTriggerData
{
    u16 triggerFrame;
    u16 typeAndMirror;
    LmETriggerTrackType trackType;
    s16 customDataIndex;
};

struct LmSCustomUserDataIndexNode
{
    u64 dataOffset; // This is the offset from the position before this value to where the data begins
    LmEAnimCustomDataType type;
    padding[align(8)];
};

struct LmAnimation
{
    float durationSeconds;
    s32 id;
    LmEAnimPropertyBits properties;
    u32 keyframeFPS;
    float version;
    u32 cacheTypesCount;
    u32 partsSizeBlocksCount;
    s16 usersCount;
    s16 playCount;

    u64 constantDataOffset;
    u64 frameDataChunkStartPointerArrayOffset;
    u64 animationFrameChunkInformationPointerArrayOffset;
    u64 frameDataOffset;
    u64 seedFrameOffset;
    u64 unpackConstantsOffset;
    u64 customUserDataIndexOffset;

    u32 customUserDataCount;
    u32 triggerCount;

    LmSAnimTriggerData triggers[triggerCount];

    u64 partsSizeBlocks[partsSizeBlocksCount];
    u64 partsSizeBlocks2[partsSizeBlocksCount];
    u64 partsSizeBlocks3[partsSizeBlocksCount];

    float count = (this.durationSeconds * this.keyframeFPS) + 1;
    u32 chunkCount = (count / 16) + 1;
    
    $ = frameDataChunkStartPointerArrayOffset;
    u64 frameDataChunkOffsets[chunkCount];
    $ = unpackConstantsOffset;
    float unpackConstants[cacheTypesCount];
    float maybeDecompressRangeScalar; // Will sometimes be NaN

    u32 customDataSize = frameDataOffset - $;
    u8 customData[customDataSize];
};

struct AnimationKeyframes
{
    u32 frameCount = std::math::ceil(anim.durationSeconds * anim.keyframeFPS) + 1;
    LmSSingleAnimFrame frames[frameCount];
};

// ------------------------------------------------
// Main Template Logic
// ------------------------------------------------

LmAnimation anim @ 0x00;
u32 frameStart = $;

LmSCustomUserDataIndexNode customUserDataIndexNodes[anim.customUserDataCount] @ anim.customUserDataIndexOffset;

if (anim.animationFrameChunkInformationPointerArrayOffset > 0)
{
    LmSAnimFrameChunkInfo frameChunkInfo @ anim.animationFrameChunkInformationPointerArrayOffset;
}

AnimationKeyframes keyframes @ frameStart;
LmSSingleAnimFrame seedFrame @ anim.seedFrameOffset;

