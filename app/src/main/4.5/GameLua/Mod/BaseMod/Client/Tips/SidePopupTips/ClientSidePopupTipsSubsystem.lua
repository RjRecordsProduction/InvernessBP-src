local ClientSidePopupTipsSubsystem = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local BaseSidePopupTipsConfig = require("GameLua.Mod.BaseMod.Client.Tips.SidePopupTips.SidePopupTipsConfig")
local ModConfig
local GetModConfig = function()
  if ModConfig then
    return ModConfig
  end
  local ModPath = Game.GetCurrentModPath()
  local ConfigPath = ModPath .. ".Client.Config.SidePopupTipsConfig"
  if slua.IsLuaModuleExists(ConfigPath) then
    ModConfig = require(ConfigPath)
    return ModConfig
  end
  return nil
end
local HasValidConfig = function()
  local Config = GetModConfig()
  if Config and Config.FacePaths then
    return true
  end
  return false
end
local TipConfig = {TipMinTime = 2, TipMaxTime = 3}
function ClientSidePopupTipsSubsystem:OnInit()
  print(bWriteLog and "ClientSidePopupTipsSubsystem:OnInit")
  self:Tick(0.5)
  self.TickTimer = self:AddGameTimer(0.5, true, function()
    self:Tick(0.5)
  end)
  self.CurTipsUI = nil
  self.TipsQueue = {}
  self.MaxTipsCount = 5
  self.IsProcessing = false
  self.TipPlayTime = 0
  self.ReconnectClearTime = 1.0
  self.bCanShowTips = true
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED_EX, self.OnApplicationReactivated, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnApplicationReactivated, self)
end
function ClientSidePopupTipsSubsystem:CallTips(TextID, FaceID, RichTextID, Param1, Param2, bAutoReduce)
  print(bWriteLog and string.format("ClientSidePopupTipsSubsystem:CallTips - TextID:%s, FaceID:%s, RichTextID:%s, Param1:%s, Param2:%s", tostring(TextID), tostring(FaceID), tostring(RichTextID), tostring(Param1), tostring(Param2)))
  if not self.bCanShowTips then
    print(bWriteLog and "ClientSidePopupTipsSubsystem:CallTips - bCanShowTips is false")
    return
  end
  if not HasValidConfig() then
    print(bWriteLog and "ClientSidePopupTipsSubsystem:CallTips - No valid config found for current mod")
    return
  end
  table.insert(self.TipsQueue, {
    TextID = TextID,
    FaceID = FaceID,
    RichTextID = RichTextID,
    Param1 = Param1,
    Param2 = Param2,
      })
  if #self.TipsQueue >= self.MaxTipsCount then
    table.remove(self.TipsQueue, 1)
  end
  if not self.IsProcessing then
    self:UpdateTips()
  end
end
function ClientSidePopupTipsSubsystem:OnApplicationReactivated()
  self.IsProcessing = false
  self.bCanShowTips = false
  self.TipsQueue = {}
  self:UpdateTips()
  self:AddGameTimer(self.ReconnectClearTime, false, function()
    self.bCanShowTips = true
  end)
end
function ClientSidePopupTipsSubsystem:UpdateTips()
  if self.CurTipsUI and self.CurTipsUI.CloseTips then
    self.CurTipsUI:CloseTips()
    self.CurTipsUI = nil
  end
  local tip = table.remove(self.TipsQueue, 1)
  if not tip then
    self.IsProcessing = false
    return
  end
  if not GameStatus.IsInFightingStatus() then
    return
  end
  if not HasValidConfig() then
    print(bWriteLog and "ClientSidePopupTipsSubsystem:UpdateTips - No valid config")
    self.IsProcessing = false
    return
  end
  self.CurTipsUI = UIManager.ShowUI(UIManager.UI_Config_InGame.SidePopupTipsUI)
  if not self.CurTipsUI then
    print(bWriteLog and "ClientSidePopupTipsSubsystem:UpdateTips - CurTipsUI is nil")
    return
  end
  self.CurTipsUI:ShowTips(tip.TextID, tip.FaceID, tip.RichTextID, tip.Param1, tip.bAutoReduce)
  self.IsProcessing = true
end
function ClientSidePopupTipsSubsystem:Tick(TickTime)
  if not self.IsProcessing then
    return
  end
  self.TipPlayTime = self.TipPlayTime + TickTime
  local bNeedUpdate = false
  if #self.TipsQueue == 0 then
    if self.TipPlayTime >= TipConfig.TipMaxTime then
      bNeedUpdate = true
    end
  elseif self.TipPlayTime >= TipConfig.TipMinTime then
    bNeedUpdate = true
  end
  if bNeedUpdate then
    self:UpdateTips()
    self.TipPlayTime = 0
  end
end
function ClientSidePopupTipsSubsystem:OnRelease()
  print(bWriteLog and "ClientSidePopupTipsSubsystem:OnRelease")
  if self.TickTimer then
    self:RemoveGameTimer(self.TickTimer)
    self.TickTimer = nil
  end
  if self.CurTipsUI then
    self.CurTipsUI:Close()
    self.CurTipsUI = nil
  end
  ModConfig = nil
  ClientSidePopupTipsSubsystem.__super.OnRelease(self)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, ClientSidePopupTipsSubsystem)