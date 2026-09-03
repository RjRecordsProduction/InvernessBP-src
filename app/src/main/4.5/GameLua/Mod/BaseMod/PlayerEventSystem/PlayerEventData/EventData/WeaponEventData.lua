local WeaponEventData = {
  CurWeaponCustomUI = {},
  WeaponCustomUIConfig = {}
}
function WeaponEventData:Init(bClient)
  WeaponEventData.__super.Init(self, bClient)
  self.ScopeListenFilter = {107005, 107001}
end
function WeaponEventData:Clear()
  WeaponEventData.__super.Clear(self)
  self.CurWeaponCustomUI = nil
end
function WeaponEventData:GetWeaponCustomUIConfig()
  if self.WeaponCustomUIConfig == nil or _G.next(self.WeaponCustomUIConfig) == nil then
    self.WeaponCustomUIConfig = {}
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local Table = GamePlayTools.GetTable("WeaponCustomUITable")
    local ToNumberTable = function(StringTable)
      local NumberTable = {}
      for _, Val in pairs(StringTable) do
        local NVal = tonumber(Val)
        if NVal ~= nil then
          table.insert(NumberTable, NVal)
        end
      end
      return NumberTable
    end
    if Table ~= nil then
      local Count = 0
      for _, RowData in pairs(Table) do
        self.WeaponCustomUIConfig[RowData.ID] = {
          CustomUIName = RowData.ID,
          WeaponIDList = ToNumberTable(RowData.WeaponIDList_a),
          AttachmentIDArray = ToNumberTable(RowData.AttachmentIDArray_a),
          NeedScope = RowData.NeedScope,
          CustomUIPath = RowData.CustomUIPath
        }
        Count = Count + 1
      end
      log_tree("WeaponEventData:GetWeaponCustomUIConfig", self.WeaponCustomUIConfig)
    else
      log_error("WeaponEventData:GetWeaponCustomUIConfig [WeaponCustomUITable] Missing")
    end
  end
  return self.WeaponCustomUIConfig
end
function WeaponEventData:GetWeaponCustomUI(UIName)
  local ConfigTable = self:GetWeaponCustomUIConfig()
  return ConfigTable[UIName]
end
function WeaponEventData:GetWeaponAttachmentList(CurWeapon)
  local AttachmentIDList = {}
  if slua.isValid(CurWeapon) then
    local AttachmentArray = CurWeapon.synData
    for AttachIndex = 0, AttachmentArray:Num() - 1 do
      local AttachmentData = AttachmentArray:Get(AttachIndex)
      if slua.IndexReference(AttachmentData, "defineID").TypeSpecificID ~= 0 and AttachmentData.operationType == 0 then
        table.insert(AttachmentIDList, AttachmentData.defineID.TypeSpecificID)
      end
    end
  end
  return AttachmentIDList
end
function WeaponEventData:FindParamInList(ID, InList)
  for index, value in ipairs(InList) do
    if value == ID then
      return index
    end
  end
  return nil
end
function WeaponEventData:CheckWeaponCustomUI(CustomUIName, CurWeapon)
  if not slua.isValid(CurWeapon) then
    return false
  end
  local ConfigTable = self:GetWeaponCustomUI(CustomUIName)
  if ConfigTable then
    return self:IsConditionReachable(ConfigTable, CurWeapon)
  end
  return false
end
function WeaponEventData:GetReachedWeaponCustomUIConfigList(CurWeapon)
  local ReachedConfigList = {}
  if slua.isValid(CurWeapon) and CurWeapon.SpecialUIName then
    local SpecialUIConfig = self:GetWeaponCustomUI(CurWeapon.SpecialUIName)
    if SpecialUIConfig then
      table.insert(ReachedConfigList, SpecialUIConfig)
      return ReachedConfigList
    end
  end
  for _, value in pairs(self:GetWeaponCustomUIConfig()) do
    if value ~= "" and self:IsConditionReachable(value, CurWeapon) then
      table.insert(ReachedConfigList, value)
    end
  end
  return ReachedConfigList
end
function WeaponEventData:IsConditionReachable(ConfigTable, CurWeapon)
  if slua.isValid(CurWeapon) then
    if ConfigTable.NeedScope then
      local OwnerPawn = CurWeapon:GetOwnerPawn()
      if slua.isValid(OwnerPawn) and not OwnerPawn.bIsGunADS then
        return false
      end
    end
    if #ConfigTable.WeaponIDList > 0 and not self:FindParamInList(CurWeapon:GetItemDefineID().TypeSpecificID, ConfigTable.WeaponIDList) then
      print(bWriteLog and "WeaponEventData:IsConditionReachable false CustomUIName:" .. ConfigTable.CustomUIName .. " CurWeapon:" .. CurWeapon:GetItemDefineID().TypeSpecificID)
      return false
    end
    local WeaponAttachmentList = self:GetWeaponAttachmentList(CurWeapon)
    if 0 < #ConfigTable.AttachmentIDArray then
      for _, AttachmentID in pairs(ConfigTable.AttachmentIDArray) do
        if self:FindParamInList(AttachmentID, WeaponAttachmentList) ~= nil then
          return true
        end
      end
    else
      return true
    end
    print(bWriteLog and "WeaponEventData:IsConditionReachable false CustomUIName:" .. ConfigTable.CustomUIName)
    return false
  end
  return false
end
function WeaponEventData:RefreshWeaponCustomUI(HandleWeaponEvent, PlayerCharacter, CurWeapon)
end
function WeaponEventData:HandleSwitchWeapon(HandleWeaponEvent, PlayerCharacter, CurWeapon)
end
function WeaponEventData:HandleChangeWeaponAttachment(HandleWeaponEvent, PlayerCharacter, CurWeapon, AttachmentID, bEquip)
end
function WeaponEventData:HandleWeaponsScopeEvent(HandleWeaponEvent, PlayerCharacter, CurWeapon)
end
function WeaponEventData:HandleWeaponClear(HandleWeaponEvent, PlayerCharacter)
  for _, CurUIName in pairs(self.CurWeaponCustomUI) do
    local CustomUIData = {CustomUIName = CurUIName}
    HandleWeaponEvent.EventActionMgr:UnDoAction(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_CUSTOMUI, PlayerCharacter, CustomUIData)
  end
end
local class = require("class")
local CEventDataBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventData.EventData.EventDataBase")
local CWeaponEventData = class(CEventDataBase, nil, WeaponEventData)
return CWeaponEventData