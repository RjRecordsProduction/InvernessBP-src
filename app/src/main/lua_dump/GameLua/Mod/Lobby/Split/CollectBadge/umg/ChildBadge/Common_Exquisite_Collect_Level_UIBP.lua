local Common_Exquisite_Collect_Level_UIBP = {}
function Common_Exquisite_Collect_Level_UIBP:ctor(_, uid, extendedParam)
  self._uid = uid or DataMgr.roleData.uid
  self._extendedParam = extendedParam or {}
end
function Common_Exquisite_Collect_Level_UIBP:OnPostInitialize()
  self:RefreshLevelUI()
end
function Common_Exquisite_Collect_Level_UIBP:SetNumDigits(prefix, onePath, tenPath, hundredPath)
  local numOne = self.UIRoot["Num_" .. prefix .. "_1"]
  local numTen = self.UIRoot["Num_" .. prefix .. "_2"]
  local numHundred = self.UIRoot["Num_" .. prefix .. "_3"]
  self:SetTexture(numOne, onePath, {sync = false})
  self:SetWidgetVisible(numTen, tenPath ~= "")
  if tenPath ~= "" then
    self:SetTexture(numTen, tenPath, {sync = false})
  end
  if slua.isValid(numHundred) then
    self:SetWidgetVisible(numHundred, hundredPath ~= "")
    if hundredPath ~= "" then
      self:SetTexture(numHundred, hundredPath, {sync = false})
    end
  end
end
function Common_Exquisite_Collect_Level_UIBP:SetHelmetIcon(light)
  if slua.isValid(self.UIRoot.Image_HelmetIcon) then
    local collect_badge_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_badge_module)
    local path = collect_badge_module:GetHelmetIconPath(light)
    self:SetTexture(self.UIRoot.Image_HelmetIcon, path, {sync = false})
  end
end
function Common_Exquisite_Collect_Level_UIBP:RefreshLevelUI()
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local uid = self._uid
  local seasonLevel = self._extendedParam.seasonLevel or 0
  local rank = self._extendedParam.rank or 0
  local totalLevel = self._extendedParam.totalLevel or 0
  local forceLight = self._extendedParam.forceLight or false
  local halo = self._extendedParam.halo or false
  local oldTotalLevel = self._extendedParam.oldTotalLevel or totalLevel
  local oldRank = self._extendedParam.oldRank or rank
  local animationType = self._extendedParam.animationType or collect_cfg.E_CollectBadge_AnimaType.Fadein
  log(bWriteLog and string.format("Common_Exquisite_Collect_Level_UIBP:RefreshLevelUI seasonLevel = %s, rank = %s, totalLevel = %s, animationType = %s, uid = %s, forceLight = %s, halo = %s, oldTotalLevel = %s, oldRank = %s", seasonLevel, rank, totalLevel, animationType, uid, forceLight, halo, oldTotalLevel, oldRank))
  local collect_badge_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_badge_module)
  self.light = collect_badge_module:CheckBadgeActivation(seasonLevel, uid, forceLight)
  self.UIRoot.WidgetSwitcher_IsGray:SetActiveWidgetIndex(self.light and 1 or 0)
  if totalLevel == 101 then
    self:SetHelmetIcon(self.light)
  else
    local nOnePath, nTenPath, nHundredPath = collect_badge_module:GetNumIcon(totalLevel, rank, self.light)
    self:SetNumDigits("New", nOnePath, nTenPath, nHundredPath)
  end
  local oOnePath, oTenPath, oHundredPath = collect_badge_module:GetNumIcon(oldTotalLevel, oldRank, self.light)
  self:SetNumDigits("Old", oOnePath, oTenPath, oHundredPath)
  if animationType == collect_cfg.E_CollectBadge_AnimaType.Fadein then
    if self.UIRoot.Fadein then
      self:PlayUserWidgetAnimation(self.UIRoot.Fadein, 0, 1, 0, 1)
    end
  elseif animationType == collect_cfg.E_CollectBadge_AnimaType.Upgrade then
    if oldRank ~= rank then
      if self.UIRoot.Levelup then
        self:PlayUserWidgetAnimation(self.UIRoot.Levelup, 0, 1, 0, 1)
      end
    elseif self.UIRoot.Upgrade then
      self:PlayUserWidgetAnimation(self.UIRoot.Upgrade, 0, 1, 0, 1)
    end
  elseif self.UIRoot.Fadein then
    self.UIRoot:PlayAnimationTo(self.UIRoot.Fadein, 1, 1, 1, 0, 1)
  end
  if halo and self.UIRoot.Loop then
    self:PlayUserWidgetAnimation(self.UIRoot.Loop, 0, 0, 0, 1)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUITemplate = class(ui_base, nil, Common_Exquisite_Collect_Level_UIBP)
return CUITemplate