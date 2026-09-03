local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local DeathReplayUIInterface = {
  UIRoot = nil,
  AvatarUID = nil,
  MarkPlayerName = nil,
  PingCheckTimer = nil,
  DeadPlayerState = nil,
  HideNetworkTime = nil,
  ShowNetworkDuration = 2.0,
  PoolNetworkPing = 250,
  bShowNetwork = false,
  CauserName = nil,
  PlayerMarkInstID = nil
}
function DeathReplayUIInterface.GetMarkMgr()
  return nil
end
function DeathReplayUIInterface.OnShow(InUIRoot)
  DeathReplayUIInterface.UIRoot = InUIRoot
end
function DeathReplayUIInterface.OnHide()
  DeathReplayUIInterface.HideTargetMark()
  if slua.isValid(DeathReplayUIInterface.UIRoot) then
    DeathReplayUIInterface.UIRoot:HideNetwork()
  end
  DeathReplayUIInterface.UIRoot = nil
  DeathReplayUIInterface.AvatarUID = nil
  DeathReplayUIInterface.CauserName = nil
  DeathReplayUIInterface.DisablePingCheck()
end
function DeathReplayUIInterface.EnableTargetMark(uPlayer, PlayerName, Show)
  local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
  print(bWriteLog and "DeathReplayUIInterface.EnableTargetMark", Show, uPlayer, PlayerName)
  if Show then
    if DeathReplayUIInterface.PlayerMarkInstID then
      InGameMarkTools.HideMapMark(DeathReplayUIInterface.PlayerMarkInstID)
    end
    if slua.isValid(uPlayer) then
      DeathReplayUIInterface.PlayerMarkInstID = InGameMarkTools.ClientAddMapMark(1035, nil, nil, nil, 4, uPlayer)
    end
  elseif DeathReplayUIInterface.PlayerMarkInstID then
    InGameMarkTools.HideMapMark(DeathReplayUIInterface.PlayerMarkInstID)
    DeathReplayUIInterface.PlayerMarkInstID = nil
  end
end
function DeathReplayUIInterface.HideTargetMark()
  if DeathReplayUIInterface.MarkPlayerName ~= nil then
    DeathReplayUIInterface.EnableTargetMark(nil, DeathReplayUIInterface.MarkPlayerName, false)
    DeathReplayUIInterface.MarkPlayerName = nil
  end
end
function DeathReplayUIInterface.ModifyHideNetworkTime(CurTime)
  DeathReplayUIInterface.HideNetworkTime = CurTime + DeathReplayUIInterface.ShowNetworkDuration
  local UIRoot = DeathReplayUIInterface.UIRoot
  if slua.isValid(UIRoot) then
    DeathReplayUIInterface.bShowNetwork = true
    UIRoot:ShowNetwork()
  end
end
function DeathReplayUIInterface.EnablePingCheck()
  print(bWriteLog and "DeathReplayUIInterface.EnablePingCheck")
  DeathReplayUIInterface.DisablePingCheck()
  local DeathReplayInstance = DeathReplayLuaInterface:GetDeathReplayInstance()
  if slua.isValid(DeathReplayInstance) then
    local uDeadPlayerState = DeathReplayInstance:GetDeadPlayerState()
    if slua.isValid(uDeadPlayerState) then
      DeathReplayUIInterface.DeadPlayerState = uDeadPlayerState
    end
  end
  DeathReplayUIInterface.PingCheckTimer = Game:SetTimer(0.5, true, function()
    if not slua.isValid(CGameState) then
      return
    end
    local CurTime = CGameState:GetServerWorldTimeSeconds()
    if slua.isValid(DeathReplayUIInterface.DeadPlayerState) then
      local Ping = (DeathReplayUIInterface.DeadPlayerState.Ping - 13) * 4
      if Ping >= DeathReplayUIInterface.PoolNetworkPing then
        DeathReplayUIInterface.ModifyHideNetworkTime(CurTime)
        return
      end
    end
    if DeathReplayUIInterface.bShowNetwork and CurTime >= DeathReplayUIInterface.HideNetworkTime then
      local UIRoot = DeathReplayUIInterface.UIRoot
      if slua.isValid(UIRoot) then
        DeathReplayUIInterface.bShowNetwork = false
        UIRoot:HideNetwork()
      end
    end
  end)
end
function DeathReplayUIInterface.DisablePingCheck()
  DeathReplayUIInterface.DeadPlayerState = nil
  if DeathReplayUIInterface.PingCheckTimer then
    Game:ClearTimer(DeathReplayUIInterface.PingCheckTimer)
    DeathReplayUIInterface.PingCheckTimer = nil
    print(bWriteLog and "DeathReplayUIInterface.DisablePingCheck")
  end
end
function DeathReplayUIInterface.RefreshCommonAvatar(ReceiveList)
  if DeathReplayUIInterface.AvatarUID == nil then
    return nil
  end
  local UIRoot = DeathReplayUIInterface.UIRoot
  if not slua.isValid(UIRoot) then
    return
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local ProfileInfo = logic_profile:GetLocalProfile(DeathReplayUIInterface.AvatarUID)
  if ProfileInfo ~= nil then
    UIRoot.Common_Avatar_BP:InitView(1, tostring(DeathReplayUIInterface.AvatarUID), ProfileInfo.picUrl, 0, ProfileInfo.cur_avatar_box_id, ProfileInfo.level, false, "")
  end
end
function DeathReplayUIInterface.ShowLeft(DeathReplayInstance)
  print(bWriteLog and "DeathReplayUIInterface.ShowLeft", DeathReplayInstance)
  if not slua.isValid(DeathReplayInstance) then
    print(bWriteLog and "DeathReplayUIInterface.ShowLeft DeathReplayInstance is nil")
    return
  end
  local UIRoot = DeathReplayUIInterface.UIRoot
  if not slua.isValid(UIRoot) then
    print(bWriteLog and "DeathReplayUIInterface.ShowLeft UIRoot is nil")
    return
  end
  UIRoot.CanvasPanel_DetailButton:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  local DeathReplayData = DeathReplayInstance.DeathReplayData
  if DeathReplayData.PlayerName == "" then
    print(bWriteLog and "DeathReplayUIInterface.ShowLeft PlayerName is Empty")
    return
  end
  DeathReplayUIInterface.CauserName = DeathReplayData.PlayerName
  DeathReplayUIInterface.ToggleFatalDamageDetailPanel(true)
  print(bWriteLog and "DeathReplayUIInterface.ShowLeft", DeathReplayData, DeathReplayData.PlayerName, DeathReplayData.KDNum, DeathReplayData.GameCount, DeathReplayData.SubType)
  UIRoot:SetKillerInfo(DeathReplayData)
  DeathReplayUIInterface.AvatarUID = nil
  DeathReplayUIInterface.AvatarUID = DeathReplayData.PlayerUID
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles({
    DeathReplayData.PlayerUID
  }, DeathReplayUIInterface.RefreshCommonAvatar, Enum_PROFILE_REPORT_CFG.DEATH_PLAY_BACK, 0, false)
  local ReplayConfig = GamePlayTools.GetCurrentConfig("ReplayConfig")
  local IconPath = ReplayConfig and ReplayConfig.DeathPlayBackID2Icon and ReplayConfig.DeathPlayBackID2Icon[DeathReplayData.SubType] or nil
  if IconPath then
    local asset_util = require("common.asset_util")
    local texture = asset_util.GetAssetSync(IconPath)
    if texture then
      local textureSizeX = texture:Blueprint_GetSizeX()
      local textureSizeY = texture:Blueprint_GetSizeY()
      local uBrush = slua.IndexReference(UIRoot.ImageCauseItem, "Brush"):clone()
      print(bWriteLog and "DeathReplayUIInterface.ShowLeft1 textureSize", textureSizeX, textureSizeY)
      uBrush.ImageSize = FVector2D(textureSizeX * 128 / textureSizeY, 128)
      UIRoot.ImageCauseItem:SetBrush(uBrush)
    end
    UIRoot.ImageCauseItem:SetBrushfromPathAsync(IconPath, false)
  else
    local uItemData = CDataTable.GetTableData("Item", DeathReplayData.SubType)
    print(bWriteLog and "DeathReplayUIInterface.ShowLeft uItemData:", uItemData and uItemData.ItemID)
    if uItemData ~= nil and uItemData.ItemID == DeathReplayData.SubType then
      local UIUtil = require("client.common.ui_util")
      local BigIconPath = UIUtil.GetItemBigIcon2(uItemData.ItemID)
      print(bWriteLog and "DeathReplayUIInterface.ShowLeft BigIconPath", uItemData.ItemID, BigIconPath)
      if BigIconPath ~= nil then
        local asset_util = require("common.asset_util")
        local texture = asset_util.GetAssetSync(BigIconPath)
        if texture then
          local textureSizeX = texture:Blueprint_GetSizeX()
          local textureSizeY = texture:Blueprint_GetSizeY()
          local uBrush = slua.IndexReference(UIRoot.ImageCauseItem, "Brush"):clone()
          print(bWriteLog and "DeathReplayUIInterface.ShowLeft2 textureSize", textureSizeX, textureSizeY)
          uBrush.ImageSize = FVector2D(textureSizeX * 128 / textureSizeY, 128)
          UIRoot.ImageCauseItem:SetBrush(uBrush)
        end
        UIRoot.ImageCauseItem:SetBrushfromPathAsync(BigIconPath, false)
      end
    end
  end
  local SelfHitInfo = DeathReplayData.SelfHitInfo
  UIRoot.TextDamage:SetText(tostring(string.format("%d", math.floor(0 < SelfHitInfo.Damage and SelfHitInfo.Damage or 0))))
  local HitCountTable = {
    [1] = SelfHitInfo.HeadShoot,
    [2] = SelfHitInfo.LimbsShoot,
    [3] = SelfHitInfo.BodyShoot,
    [4] = SelfHitInfo.HandShoot,
    [5] = SelfHitInfo.FootShoot
  }
  log_tree("DeathReplayUIInterface.ShowLeft SelfHitInfo:" .. SelfHitInfo.Damage, HitCountTable)
  for BodyPart, HitCount in pairs(HitCountTable) do
    local CanvasHitPart = UIRoot[string.format("LeftCanvas_%d", BodyPart)]
    if 0 < HitCount then
      CanvasHitPart:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      local TextHitCount = UIRoot[string.format("LHitCount_%d", BodyPart)]
      TextHitCount:SetText(string.format("%d", HitCount))
    else
      CanvasHitPart:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    end
  end
  local OtherHitInfo = DeathReplayData.OtherHitInfo
  UIRoot.TextHurt:SetText(tostring(string.format("%d", math.floor(0 < OtherHitInfo.Damage and OtherHitInfo.Damage or 0))))
  HitCountTable = {
    [1] = OtherHitInfo.HeadShoot,
    [2] = OtherHitInfo.LimbsShoot,
    [3] = OtherHitInfo.BodyShoot,
    [4] = OtherHitInfo.HandShoot,
    [5] = OtherHitInfo.FootShoot
  }
  log_tree("DeathReplayUIInterface.ShowLeft OtherHitInfo:" .. OtherHitInfo.Damage, HitCountTable)
  for BodyPart, HitCount in pairs(HitCountTable) do
    local CanvasHitPart = UIRoot[string.format("RightCanvas_%d", BodyPart)]
    if 0 < HitCount then
      CanvasHitPart:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      local TextHitCount = UIRoot[string.format("RHitCount_%d", BodyPart)]
      TextHitCount:SetText(string.format("%d", HitCount))
    else
      CanvasHitPart:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    end
  end
  UIRoot:RefreshAliasAndRankInfo(DeathReplayData.AliasID, DeathReplayData.AliasTitle, DeathReplayData.AliasNation, DeathReplayData.AliasRank, DeathReplayData.AliasPartnerName, DeathReplayData.AliasPartnerRelation, DeathReplayData.SegmentLevel, DeathReplayData.AliasRankID or 0)
  local uPlayer = DeathReplayInstance:GetDeadCharacter()
  if slua.isValid(uPlayer) then
    print("DeathReplayUIInterface.ShowLeft EnableTargetMark", uPlayer, uPlayer:GetPlayerNameSafety())
    DeathReplayUIInterface.EnableTargetMark(uPlayer, uPlayer:GetPlayerNameSafety(), true)
    DeathReplayUIInterface.EnablePingCheck()
  end
end
function DeathReplayUIInterface.ShowRight(DeathReplayInstance, EnableMark, EnableOBBullet)
end
function DeathReplayUIInterface.RestoreSettings()
  local MarkMgr = DeathReplayUIInterface.GetMarkMgr()
  if slua.isValid(MarkMgr) then
    DeathReplayLuaInterface.SettingMark = MarkMgr.EnableMark
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.IsToggleOBBulletTrackEffect ~= nil then
    DeathReplayLuaInterface.SettingOBBullet = uPlayerController:IsToggleOBBulletTrackEffect()
  end
end
function DeathReplayUIInterface.MaskEnable(Enable)
  print(bWriteLog and "DeathReplayUIInterface.MaskEnable", Enable)
  local UIRoot = DeathReplayUIInterface.UIRoot
  if slua.isValid(UIRoot) and slua.isValid(UIRoot.IngameFade_UIBP) then
    UIRoot.IngameFade_UIBP:MaskEnable(Enable)
  end
end
function DeathReplayUIInterface.MaskFade(FadeOut, Rate)
  print(bWriteLog and "DeathReplayUIInterface.MaskFade", FadeOut, Rate)
  local UIRoot = DeathReplayUIInterface.UIRoot
  if slua.isValid(UIRoot) and slua.isValid(UIRoot.IngameFade_UIBP) then
    Rate = Rate or 1.0
    UIRoot.IngameFade_UIBP:MaskFade(0.0, Rate, FadeOut)
  end
end
function DeathReplayUIInterface.OnPausePlay(Pause)
  local UIRoot = DeathReplayUIInterface.UIRoot
  if slua.isValid(UIRoot) then
  end
end
function DeathReplayUIInterface.IsFatalDamageDetailPanelVisible()
  if slua.isValid(DeathReplayUIInterface.UIRoot) and DeathReplayUIInterface.UIRoot.CanvasLeft then
    local nVisibility = DeathReplayUIInterface.UIRoot.CanvasLeft:GetVisibility()
    return nVisibility ~= UEnums.ESlateVisibility.Hidden and nVisibility ~= UEnums.ESlateVisibility.Collapsed
  end
  return false
end
function DeathReplayUIInterface.ToggleFatalDamageDetailPanel(bIsShow)
  print(bWriteLog and "DeathReplayUIInterface.ToggleFatalDamageDetailPanel", bIsShow, DeathReplayUIInterface._bIsForceHideFatalDamageDetailPanel)
  FuncUtil.FormatLog("bIsShow=%s", tostring(bIsShow))
  local uUIRoot = DeathReplayUIInterface.UIRoot
  if bIsShow == true then
    if slua.isValid(uUIRoot) and uUIRoot.CanvasLeft and not DeathReplayUIInterface._bIsForceHideFatalDamageDetailPanel then
      print(bWriteLog and "DeathReplayUIInterface.ToggleFatalDamageDetailPanel", bIsShow)
      uUIRoot.CanvasLeft:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      uUIRoot.CanvasPanel_DetailButton:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif bIsShow == false then
    if slua.isValid(uUIRoot) and uUIRoot.CanvasLeft then
      uUIRoot.CanvasLeft:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
      uUIRoot.CanvasPanel_DetailButton:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    end
  elseif bIsShow == nil then
    DeathReplayUIInterface.ToggleFatalDamageDetailPanel(not DeathReplayUIInterface.IsFatalDamageDetailPanelVisible())
  end
end
function DeathReplayUIInterface.ForceHideFatalDamageDetailPanel(bIsForceHide)
  FuncUtil.FormatLog("bIsForceHide=%s", tostring(bIsForceHide))
  if bIsForceHide then
    DeathReplayUIInterface._bIsForceHideFatalDamageDetailPanel = true
  else
    DeathReplayUIInterface._bIsForceHideFatalDamageDetailPanel = nil
  end
end
return DeathReplayUIInterface