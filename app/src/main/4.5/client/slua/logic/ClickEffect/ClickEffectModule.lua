local ClickEffectModule = {}
function ClickEffectModule:DefineAndResetData()
  self.CurShowEffectId = 0
  self.CurUsedEffectId = 0
end
function ClickEffectModule:OnInitialize()
end
function ClickEffectModule:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_INIT, self.OnDepotDataInit, self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self.OnDownloadFinish, self)
end
function ClickEffectModule:OnLogOut()
  self.CurUsedEffectId = 0
  self.CurShowEffectId = 0
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_CLICK_EFFECT_CHANGED, self.CurShowEffectId)
end
function ClickEffectModule:OnDownloadFinish(_, __, eventData)
  if not eventData or not eventData.itemID then
    return
  end
  if eventData.itemID ~= self.CurUsedEffectId then
    return
  end
  self.CurShowEffectId = self.CurUsedEffectId
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_CLICK_EFFECT_CHANGED, self.CurShowEffectId)
end
function ClickEffectModule:OnDepotDataInit()
  local clickEffectInsID = DataMgr.common_depot_puton and DataMgr.common_depot_puton.click_effect or 0
  if clickEffectInsID ~= 0 then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetHallDepotItemDataByInsID(clickEffectInsID)
    self:SetCurrentUse(itemData.resID)
  end
end
function ClickEffectModule:GetCurUsedEffectID()
  return self.CurUsedEffectId
end
function ClickEffectModule:GetCurShowEffectID()
  return self.CurShowEffectId
end
function ClickEffectModule:SetCurrentUse(itemID)
  itemID = tonumber(itemID)
  self.CurUsedEffectId = itemID
  if itemID ~= 0 then
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    if PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {itemID}) == PufferConst.ENUM_DownloadState.Done then
      self.CurShowEffectId = self.CurUsedEffectId
      EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_CLICK_EFFECT_CHANGED, self.CurShowEffectId)
    else
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {itemID}, nil, nil, {bSkipPopUp = true})
    end
  else
    self.CurShowEffectId = self.CurUsedEffectId
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_CLICK_EFFECT_CHANGED, self.CurShowEffectId)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CClickEffectModule = class(CModuleBase, nil, ClickEffectModule)
return CClickEffectModule