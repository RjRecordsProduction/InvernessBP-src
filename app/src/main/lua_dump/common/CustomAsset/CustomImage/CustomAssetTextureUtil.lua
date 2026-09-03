local CustomAssetTextureUtil = {}
local UAETableManager = import("UAETableManager")
local UETextureGroup = import("TextureGroup")
local UCustomAssetImageManager = import("CustomAssetImageManager")
CustomAssetTextureUtil.TextureGroup = {
  UI = UETextureGroup.TEXTUREGROUP_UI,
  Texture = UETextureGroup.TEXTUREGROUP_World
}
CustomAssetTextureUtil.CompressionFormatProto = {
  UNKNOWN = 0,
  ETC2_RGBA = 2,
  ASTC_4x4 = 3
}
CustomAssetTextureUtil.CompressionFormatUnreal = {PF_ETC2_RGBA = 47, PF_ASTC_4x4 = 50}
local ReservedSize = 60
function CustomAssetTextureUtil.LuaReserveTexture(PixelFormat, TexGroup)
  PixelFormat = PixelFormat or CustomAssetTextureUtil.GetPixelFormat(0)
  TexGroup = TexGroup or CustomAssetTextureUtil.TextureGroup.UI
  return UCustomAssetImageManager.LuaReserveTexture(PixelFormat, TexGroup, ReservedSize, ReservedSize)
end
function CustomAssetTextureUtil.LuaReserveTexture2(PixelFormat, TexGroup, OtherTex)
  if not slua.isValid(OtherTex) then
    print(bWriteLog and "CustomAssetTextureUtil.LuaReserveTexture2 OtherTex is nil")
    return CustomAssetTextureUtil.LuaReserveTexture(PixelFormat, TexGroup)
  end
  PixelFormat = PixelFormat or CustomAssetTextureUtil.GetPixelFormat(0)
  TexGroup = TexGroup or CustomAssetTextureUtil.TextureGroup.UI
  return UCustomAssetImageManager.LuaReserveTexture2(PixelFormat, TexGroup, OtherTex)
end
function CustomAssetTextureUtil.LuaUpdateTextureResource2(Texture, TexGroup, Width, Height, MipIndex, PixelFormat, ImageBinaryData)
  if Texture == nil then
    print(bWriteLog and "CustomAssetTextureUtil.LuaUpdateTextureResource2 Texture is nil")
    return
  end
  if ImageBinaryData == nil or #ImageBinaryData <= 0 then
    print(bWriteLog and "CustomAssetTextureUtil.LuaUpdateTextureResource2 ImageBinaryData is nil")
    return
  end
  TexGroup = TexGroup or CustomAssetTextureUtil.TextureGroup.UI
  Width = Width or ReservedSize
  Height = Height or ReservedSize
  MipIndex = MipIndex or 0
  PixelFormat = CustomAssetTextureUtil.GetPixelFormat(PixelFormat or 0)
  UCustomAssetImageManager.LuaUpdateTextureResource2(Texture, TexGroup, Width, Height, MipIndex, PixelFormat, ImageBinaryData)
  print(bWriteLog and "CustomAssetTextureUtil:UpdateTextureResource2" .. "TexGroup" .. tostring(TexGroup) .. " Width:" .. tostring(Width) .. " Height:" .. tostring(Height) .. " MipIndex" .. tostring(MipIndex) .. " Format:" .. tostring(Format))
end
function CustomAssetTextureUtil.LuaUpdateTextureResourceByPB(Texture, CompressedTexture_PB)
  if CompressedTexture_PB == nil then
    print(bWriteLog and "CustomAssetTextureUtil:LuaUpdateTextureResourceByPB PB struct error")
    return
  end
  if CustomAssetTextureUtil.PlatformUseRowBinary() then
    local FileSummary = CustomAssetTextureUtil.ReadImageSummary(CompressedTexture_PB)
    if FileSummary == nil then
      print(bWriteLog and "CustomAssetTextureUtil:LuaUpdateTextureResourceByPB ImageSummary error")
      return
    end
    local Width = FileSummary.Width
    local Height = FileSummary.Height
    local Format = 0
    local MipIndex = 0
    CustomAssetTextureUtil.LuaUpdateTextureResource2(Texture, CustomAssetTextureUtil.TextureGroup.UI, Width, Height, MipIndex, Format, CompressedTexture_PB)
    return
  end
  if CompressedTexture_PB.data == nil or CompressedTexture_PB.metadata == nil then
    print(bWriteLog and "CustomAssetTextureUtil:LuaUpdateTextureResourceByPB PB struct error data or metadata is nil")
    return
  end
  if not slua.isValid(Texture) then
    print(bWriteLog and "CustomAssetTextureUtil:LuaUpdateTextureResourceByPB Texture is nil")
    return
  end
  local Format = CustomAssetTextureUtil.PFProto2Unreal(CompressedTexture_PB.metadata.compression)
  if Format == nil then
    print(bWriteLog and "CustomAssetTextureUtil:LuaUpdateTextureResourceByPB Texture format not support:" .. tostring(CompressedTexture_PB.metadata.compression))
    return
  end
  local Width = CompressedTexture_PB.metadata.width
  local Height = CompressedTexture_PB.metadata.height
  local MipIndex = 0
  CustomAssetTextureUtil.LuaUpdateTextureResource2(Texture, CustomAssetTextureUtil.TextureGroup.UI, Width, Height, MipIndex, Format, CompressedTexture_PB.data)
end
function CustomAssetTextureUtil.ReadTextureFormat(Texture)
  return UCustomAssetImageManager.ReadPixelFormat(Texture)
end
function CustomAssetTextureUtil.ReadImageSummary(ImageBinaryData)
  local Summary = UCustomAssetImageManager.ReadImageSummary(ImageBinaryData)
  local IsValid = UCustomAssetImageManager.IsValidImageSummary(Summary)
  if not IsValid then
    return nil
  end
  return Summary
end
function CustomAssetTextureUtil.GetPixelFormat(PixelFormat)
  return UCustomAssetImageManager.GetPixelFormat(PixelFormat)
end
function CustomAssetTextureUtil.PFProto2Unreal(ProtoFormat)
  if ProtoFormat == nil then
    return nil
  end
  local CompressionFormatProto = CustomAssetTextureUtil.CompressionFormatProto
  local CompressionFormatUnreal = CustomAssetTextureUtil.CompressionFormatUnreal
  if ProtoFormat == CompressionFormatProto.UNKNOWN then
    return CustomAssetTextureUtil.GetPixelFormat(0)
  elseif ProtoFormat == CompressionFormatProto.ETC2_RGBA then
    return CompressionFormatUnreal.PF_ETC2_RGBA
  elseif ProtoFormat == CompressionFormatProto.ASTC_4x4 then
    return CompressionFormatUnreal.PF_ASTC_4x4
  end
  return nil
end
function CustomAssetTextureUtil.GetObjectPath(Texture)
  if not slua.isValid(Texture) then
    return ""
  end
  return UCustomAssetImageManager.GetObjectPath(Texture)
end
function CustomAssetTextureUtil.PlatformUseRowBinary()
  return CustomAssetTextureUtil.IsWindows()
end
function CustomAssetTextureUtil.IsWindows()
  local UCreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
  return UCreativeModeBlueprintLibrary.IsWindows()
end
return CustomAssetTextureUtil