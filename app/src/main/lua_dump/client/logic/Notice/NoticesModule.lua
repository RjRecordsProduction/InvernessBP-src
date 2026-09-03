local NoticesModule = {}
local NoticesConst = require("client.logic.Notice.NoticesConst")
local NoticesUtil = require("client.logic.Notice.NoticesUtil")
function NoticesModule:DefineAndResetData()
  self.CurNoticeScene = nil
  self.SceneData = {}
  self.ShownScene = {}
end
function NoticesModule:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_NOTICE, self.OnJumpShowLobbyNotice, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_TXMISSION_NOTICE, self.OnJumpShowTxMissionNotice, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_HOSTED_GAMELET_FACE_SLAP, self.OnJumpShowGameletNotice, self)
end
function NoticesModule:OnLogOut()
  self:ClearNoticesScene()
  self:_LogoutReset()
end
function NoticesModule:OnJumpShowLobbyNotice()
  self:ShowNotice(NoticesConst.Scene.Lobby)
end
function NoticesModule:OnJumpShowTxMissionNotice()
  self:ShowNotice(NoticesConst.Scene.TxMission)
end
function NoticesModule:OnJumpShowGameletNotice()
  self:ShowNotice(NoticesConst.Scene.Gamelet)
end
function NoticesModule:CanShowNotice(noticeScene)
  if not noticeScene then
    log(bWriteLog and "NoticesModule:CanShowNotice. noticeScene is nil")
    return false
  end
  if self.ShownScene[noticeScene] then
    log(bWriteLog and "NoticesModule:CanShowNotice. noticeScene has been shown")
    return false
  end
  local Utility = require("common.utility")
  local GameAutotest = Utility.GetGameInstanceSubsystemByName("AutoTestSubsystem")
  if slua.isValid(GameAutotest) then
    local bUIAutoTest = GameAutotest:IsUIAutoTest()
    if bUIAutoTest then
      print(bWriteLog and "NoticesModule:CanShowNotice return false of bUIAutoTest=", bUIAutoTest)
      return false
    end
  end
  local common_config = require("client.slua.common.common_config")
  if common_config:IsBlockingPopupTip() then
    return false
  end
  local SceneData = self:_GetProxy(noticeScene)
  if not SceneData then
    log_format("NoticesModule:CanShowNotice. SceneData is nil, noticeScene=%s ", tostring(noticeScene))
    return false
  end
  SceneData:Init()
  return SceneData:HasData()
end
function NoticesModule:ShowNotice(noticeScene)
  if not self:CanShowNotice(noticeScene) then
    log_format("NoticesModule:ShowNotice. noticeScene=%s can't show NoticeScene", tostring(noticeScene))
    return
  end
  self.CurNoticeScene = noticeScene
  local SceneData = self:_GetProxy(noticeScene)
  local params = SceneData:GetShowParams()
  UIManager.ShowUI(UIManager.UI_Config.Notices_Main_UIBP, noticeScene, params)
end
function NoticesModule:GetCurNoticeScene()
  return self.CurNoticeScene
end
function NoticesModule:ClearNoticesScene()
  self.CurNoticeScene = nil
end
function NoticesModule:IsLeftNotices()
  if not self.CurNoticeScene then
    return false
  end
  local SceneData = self:_GetProxy(self.CurNoticeScene)
  if not SceneData then
    return false
  end
  return SceneData:IsLeftNotices()
end
function NoticesModule:ShowLeftNotices()
  if not self.CurNoticeScene then
    return
  end
  self:ShowNotice(self.CurNoticeScene)
end
function NoticesModule:PreHandleDependResource(noticeScene)
  if not noticeScene then
    return
  end
  local SceneData = self:_GetProxy(noticeScene)
  if not SceneData then
    return false
  end
  SceneData:Init()
  return SceneData:PreHandleDependResource()
end
function NoticesModule:GetSeqNextData(noticeScene)
  if not noticeScene then
    return
  end
  local SceneData = self:_GetProxy(noticeScene)
  if not SceneData then
    return false
  end
  return SceneData:GetSeqNextData()
end
function NoticesModule:OnSeqEnd()
  local Scene = self.CurNoticeScene
  self:ClearNoticesScene()
  if Scene and self.SceneData[Scene] then
    local sceneData = self.SceneData[Scene]
    local CanShowMultiTime = NoticesConst.MultiShowNotices[Scene] or false
    self.SceneData[Scene] = nil
    sceneData:Dispose()
    if not CanShowMultiTime then
      self.ShownScene[Scene] = true
    end
  end
end
function NoticesModule:ClearTargetNotice(noticeScene)
  if not noticeScene then
    return
  end
  if not self.SceneData[noticeScene] then
    return
  end
  local sceneData = self.SceneData[noticeScene]
  self.SceneData[noticeScene] = nil
  sceneData:Dispose()
end
function NoticesModule:_GetProxy(noticeScene)
  if self.SceneData[noticeScene] then
    return self.SceneData[noticeScene]
  end
  local path = string.format("client.logic.Notice.SceneData.NoticesSceneData_%s", noticeScene)
  local class = require(path)
  local SceneData = class()
  self.SceneData[noticeScene] = SceneData
  return SceneData
end
function NoticesModule:_LogoutReset()
  local toRemoveSceneData = {}
  for noticeScene, proxy in pairs(self.SceneData) do
    if NoticesConst.LogoutResetNotices[noticeScene] then
      log_format("NoticesModule:_LogoutReset. Reset Proxy:%s", tostring(noticeScene))
      proxy:Dispose()
      toRemoveSceneData[#toRemoveSceneData + 1] = noticeScene
    end
  end
  for _, scene in ipairs(toRemoveSceneData) do
    self.SceneData[scene] = nil
  end
  local toRemoveShown = {}
  for noticeScene, _ in pairs(self.ShownScene) do
    if NoticesConst.LogoutResetNotices[noticeScene] then
      log_format("NoticesModule:_LogoutReset. Reset Shown:%s", tostring(noticeScene))
      toRemoveShown[#toRemoveShown + 1] = noticeScene
    end
  end
  for _, scene in ipairs(toRemoveShown) do
    self.ShownScene[scene] = nil
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CNoticesModule = class(CModuleBase, nil, NoticesModule)
return CNoticesModule