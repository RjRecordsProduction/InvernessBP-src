local WoW_CommonEnterRoomTips_UIBP = {}
local UGC_Inventory = require("client.slua.logic.ugc.ugc_Inventory")
function WoW_CommonEnterRoomTips_UIBP:ctor(_, UpInRoomType)
  self.PlayingAnimaProfile = nil
  self.PlayAnimationList = {}
  self.UpInRoomType = UpInRoomType or 1
end
function WoW_CommonEnterRoomTips_UIBP:OnInitialize()
end
function WoW_CommonEnterRoomTips_UIBP:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_ROOM, EVENTID_ROOM_ENTRY_UPDATE_TIPS, self.AddPlayerToUpRoomAnima, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_END_ANIMATION_ROOMTIPS, self.EndAnimationRoomTips, self)
end
function WoW_CommonEnterRoomTips_UIBP:OnPostInitialize()
end
function WoW_CommonEnterRoomTips_UIBP:AddUpRoomBP(profileList)
  if not profileList or not next(profileList) then
    return
  end
  local UGC_Inventory = require("client.slua.logic.ugc.ugc_Inventory")
  local logic_ugc_inventory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_inventory)
  local profile = profileList[1]
  local SubTabID = UGC_Inventory.InventoryList[2][2].SubTabID
  if not profile or not profile.ugc_personal_dress then
    log(bWriteLog and "UGCRoomWaitingPanel:SetUpRoomAnima: profile is nil")
    return
  end
  if not profile.ugc_personal_dress[SubTabID] or not profile.ugc_personal_dress[SubTabID][1] then
    log(bWriteLog and "UGCRoomWaitingPanel:SetUpRoomAnima: profile.ugc_personal_dress[SubTabID] is nil")
    return
  end
  if self.PlayingAnimaProfile then
    local Add = true
    for k, v in pairs(self.PlayAnimationList) do
      if v.uid == profile.uid or v.uid == self.PlayingAnimaProfile.uid then
        Add = false
      end
    end
    if Add and profile.uid ~= self.PlayingAnimaProfile.uid then
      table.insert(self.PlayAnimationList, profile)
    end
    return
  end
  local PlayProfile = self.PlayAnimationList[1] or profile
  table.remove(self.PlayAnimationList, 1)
  local RoomData = logic_ugc_inventory:GetUpRoomTipsData(profile.ugc_personal_dress[SubTabID][1])
  if RoomData and RoomData.WidgetPath and RoomData.WidgetPath ~= "" then
    self.PlayingAnimaProfile = PlayProfile
    local UpRoom_BP = logic_ugc_inventory:AddUpBPEffectByCreateChildWindow(self, RoomData.WidgetPath, self.UIRoot.Panel_EnterRoomTips1, false, profile.nickName, 1050128)
  elseif next(self.PlayAnimationList) then
    self:EndAnimationRoomTips()
  end
end
function WoW_CommonEnterRoomTips_UIBP:AddPlayerToUpRoomAnima(_, _, UID, TypeUI)
  log(bWriteLog and "UGCRoomWaitingPanel:AddPlayerToUpRoomAnima")
  if not UID then
    return
  end
  if TypeUI and TypeUI ~= self.UpInRoomType then
    log(bWriteLog and "UGCRoomWaitingPanel:AddPlayerToUpRoomAnima: TypeUI is not self.UpInRoomType")
    return
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles({UID}, function(profileList)
    self:AddUpRoomBP(profileList)
  end, Enum_PROFILE_REPORT_CFG.UGC, nil, true)
end
function WoW_CommonEnterRoomTips_UIBP:EndAnimationRoomTips()
  self.PlayingAnimaProfile = nil
  if next(self.PlayAnimationList) then
    local profile = {}
    table.insert(profile, self.PlayAnimationList[1])
    self:AddUpRoomBP(profile)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CWoW_CommonEnterRoomTips_UIBP = class(ui_base, nil, WoW_CommonEnterRoomTips_UIBP)
return CWoW_CommonEnterRoomTips_UIBP