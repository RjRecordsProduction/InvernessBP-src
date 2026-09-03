local SidePopupTipsConfig = {}
SidePopupTipsConfig.FacePaths = {
  [1] = "/Game/BluePrints/UI/GhostTips/Icon/ZD_Image_Ghost_Default.ZD_Image_Ghost_Default"
}
SidePopupTipsConfig.VoicePaths = {
  [1] = "/Game/BluePrints/UI/GhostTips/Icon/ZD_Image_Ghost_Voice02_Effect.ZD_Image_Ghost_Voice02_Effect"
}
SidePopupTipsConfig.DefaultFaceID = 1
function SidePopupTipsConfig.GetFacePath(Config, FaceID)
  if not Config then
    return nil
  end
  local FacePaths = Config.FacePaths
  if not FacePaths then
    return nil
  end
  local Path = FacePaths[FaceID]
  if Path then
    return Path
  end
  local DefaultFaceID = Config.DefaultFaceID or SidePopupTipsConfig.DefaultFaceID
  if DefaultFaceID and FacePaths[DefaultFaceID] then
    return FacePaths[DefaultFaceID]
  end
  return nil
end
function SidePopupTipsConfig.GetVoicePath(Config, VoiceID)
  if not Config then
    return nil
  end
  local VoicePaths = Config.VoicePaths
  if not VoicePaths then
    return nil
  end
  return VoicePaths[VoiceID]
end
return SidePopupTipsConfig