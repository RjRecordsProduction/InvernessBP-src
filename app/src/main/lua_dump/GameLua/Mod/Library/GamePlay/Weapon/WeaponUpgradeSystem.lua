local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local WeaponUpgradeSystem = {}
function WeaponUpgradeSystem:OnInit()
  print(bWriteLog and "WeaponUpgradeSystem:OnInit ")
  if Client then
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_UPGRADEINFO_CHANGE, self.HandleUpgradeChangeInfoInClient, self)
  else
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_UPGRADEINFO_CHANGE, self.HandleUpgradeChangeInfoInDS, self)
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_UPGRADEINFO_START, self.HandleWeaponUpgradeStartInDS, self)
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_UPGRADE_FINISH, self.HandleWeaponUpgradeFinishInDS, self)
  end
  self.bGetWeaponWithNewTypeOrID = false
end
function WeaponUpgradeSystem:OnRelease()
  print(bWriteLog and "WeaponUpgradeSystem:OnRelease")
  WeaponUpgradeSystem.__super.OnRelease(self)
end
function WeaponUpgradeSystem:IsUpgradeWeaponType(uWeapon)
end
function WeaponUpgradeSystem:IsWeaponCanUpgrade(uWeapon)
  if not (slua.isValid(uWeapon) and uWeapon.HasUpgrade) or uWeapon:HasUpgrade() then
    return false
  end
  return true
end
function WeaponUpgradeSystem:GetUpgradeCfgByID(UpgradeID, uWeapon, SpecialType)
end
function WeaponUpgradeSystem:GetNextUpgradeCfg(UpgradeItemID, uWeapon, SpecialType)
end
function WeaponUpgradeSystem:GetWeaponUpgradeTime(Weapon)
end
function WeaponUpgradeSystem:GetWeaponUpgradeStrings(Weapon)
end
function WeaponUpgradeSystem:IsUpgradeValid(uWeapon, UpgradeItemID)
  if not self:IsWeaponCanUpgrade(uWeapon) then
    print(bWriteLog and "WeaponUpgradeSystem:IsUpgradeValid: Can not Upgrade ", uWeapon)
    return
  end
  local WeaponUpgradeCfg = self:GetNextUpgradeCfg(UpgradeItemID, uWeapon) or {}
  local SpecialWeaponUpgradeCfg = self:GetNextUpgradeCfg(UpgradeItemID, uWeapon, 1) or {}
  if not next(WeaponUpgradeCfg) and not next(SpecialWeaponUpgradeCfg) then
    print(bWriteLog and "WeaponUpgradeSystem:IsUpgradeValid: not Data ", uWeapon)
    return
  end
  return true
end
function WeaponUpgradeSystem:HandleUpgradeChangeInfoInClient(EventType, EventID, uWeapon)
  print(bWriteLog and "WeaponUpgradeSystem:HandleUpdateUpgradeInfoInClient: ", uWeapon)
  if not slua.isValid(uWeapon) then
    return
  end
  local UpgradeID = uWeapon:GetUpgradeInfoID()
  local SpecialUpgradeCfg = self:GetUpgradeCfgByID(UpgradeID, uWeapon, 1)
  self:AddAttrModifierSpecial(uWeapon, UpgradeID, SpecialUpgradeCfg)
end
function WeaponUpgradeSystem:HandleUpgradeChangeInfoInDS(nEventType, nEventID, uWeapon)
  print(bWriteLog and "WeaponUpgradeSystem:HandleUpgradeChangeInfoInDS: ", uWeapon)
  if not slua.isValid(uWeapon) then
    return
  end
  local UpgradeID = uWeapon:GetUpgradeInfoID()
  local WeaponUpgradeCfg = self:GetUpgradeCfgByID(UpgradeID, uWeapon) or {}
  self:AddUpgradeAttrModifier(uWeapon, WeaponUpgradeCfg)
  local SpecialUpgradeCfg = self:GetUpgradeCfgByID(UpgradeID, uWeapon, 1)
  self:AddAttrModifierSpecial(uWeapon, UpgradeID, SpecialUpgradeCfg)
end
function WeaponUpgradeSystem:HandleWeaponUpgradeStartInDS(nEventType, nEventID, uCharacter, SkillID, LuaTable, BBLuaTable)
  local SkillSlot = BBLuaTable.WeaponSlot
  local UpgradeItemID = BBLuaTable.UpgradeItemID
  local uWeapon = slua.isValid(uCharacter) and uCharacter:GetCurrentWeapon()
  local WeaponSlot = slua.isValid(uWeapon) and uWeapon:GetWeaponSlot()
  print(bWriteLog and "WeaponUpgradeSystem:HandleWeaponUpgradeStartInDS: ", WeaponSlot, SkillSlot)
  if WeaponSlot ~= SkillSlot or not self:IsUpgradeValid(uWeapon, UpgradeItemID) then
    print(bWriteLog and "WeaponUpgradeSystem:HandleWeaponUpgradeStartInDS fail: ", WeaponSlot, SkillSlot, UpgradeItemID)
    local UAESkillManagerComponent = import("UAESkillManagerComponent")
    local SkillComponent = UAESkillManagerComponent and uCharacter:GetComponentByClass(UAESkillManagerComponent)
    if slua.isValid(SkillComponent) then
      local UTSkillStopReason = import("UTSkillStopReason")
      SkillComponent:StopSkill(SkillID, UTSkillStopReason.SkillStopReason_Interrupted)
    end
  end
end
function WeaponUpgradeSystem:HandleWeaponUpgradeFinishInDS(EventType, EventID, uCharacter, SkillID, LuaTable, BBLuaTable)
  local UpgradeItemID = BBLuaTable.UpgradeItemID
  print(bWriteLog and "WeaponUpgradeSystem:HandleWeaponUpgradeFinishInDS: ", UpgradeItemID)
  local uWeapon = slua.isValid(uCharacter) and uCharacter:GetCurrentWeapon()
  if not self:IsUpgradeValid(uWeapon, UpgradeItemID) then
    return
  end
  local SkillManager = uCharacter:GetSkillManager()
  if not SkillManager then
    print(bWriteLog and "WeaponUpgradeSystem:HandleWeaponUpgradeFinishInDS: not SkillManager")
    return
  end
  self:BeforeWeaponUpgrade(uWeapon, UpgradeItemID)
  SkillManager:TriggerStringEvent(SkillID, "WeaponUpgradeScucess")
  self:DoUpgrade(uWeapon, UpgradeItemID)
  self:AfterWeaponUpgrade(uWeapon, UpgradeItemID)
  local PromptID = self:GetWeaponUpgradeCfg(uWeapon, "PromptID")
  if PromptID then
    Game:UIShowTips(uCharacter.PlayerKey, PromptID)
  end
end
function WeaponUpgradeSystem:DoUpgrade(uWeapon, UpgradeItemID)
  if slua.isValid(uWeapon) then
    uWeapon:SetUpgradeInfoID(UpgradeItemID)
  end
end
function WeaponUpgradeSystem:BeforeWeaponUpgrade(uWeapon, UpgradeItemID)
  print(bWriteLog and "WeaponUpgradeSystem:BeforeWeaponUpgrade ", uWeapon, UpgradeItemID)
end
function WeaponUpgradeSystem:AfterWeaponUpgrade(uWeapon, UpgradeItemID)
  if not slua.isValid(uWeapon) then
    return
  end
  local uWeaponController = uWeapon:GetOwnerController()
  if not slua.isValid(uWeaponController) then
    return
  end
  print(bWriteLog and "WeaponUpgradeSystem:AfterWeaponUpgrade ", uWeapon, UpgradeItemID)
  local UID = uWeaponController.UID
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  PlayerDataMgr.SetWeaponUpgradeTlog(UID, UpgradeItemID, uWeapon:GetWeaponID(), uWeapon:GetUpgradeInfoID())
end
function WeaponUpgradeSystem:RemoveUpgradeAttrModifier(uWeapon)
  local uAttrModifierCompoment = slua.isValid(uWeapon) and uWeapon.AttrModifierCompoment
  if not slua.isValid(uAttrModifierCompoment) then
    return
  end
  for i = 0, uWeapon.UpgradeBModifyIdArray:Num() - 1 do
    uAttrModifierCompoment:RemoveModifyItemFromCache(uWeapon.UpgradeBModifyIdArray:Get(i))
  end
  uWeapon.UpgradeBModifyIdArray:Clear()
end
function WeaponUpgradeSystem:AddUpgradeAttrModifier(uWeapon, UpgradeCfg)
  if not UpgradeCfg or not next(UpgradeCfg) then
    return
  end
  local uAttrModifierCompoment = slua.isValid(uWeapon) and uWeapon.AttrModifierCompoment
  if not slua.isValid(uAttrModifierCompoment) then
    return
  end
  for _, Cfg in pairs(UpgradeCfg) do
    local BModifyId = uAttrModifierCompoment:AddBModifyAndCacheWithCParam(Cfg.AttrName, Cfg.OP, Cfg.Value, false)
    uWeapon.UpgradeBModifyIdArray:Add(BModifyId)
    if Cfg.AttrName == "MaxBulletNumInOneClip" and Cfg.OP == 2 then
      uWeapon.CurMaxBulletNumInOneClip = uWeapon.CurMaxBulletNumInOneClip + Cfg.Value
    end
  end
  print(bWriteLog and "WeaponUpgradeSystem:AddUpgradeAttrModifier: ", uWeapon, UpgradeCfg)
end
function WeaponUpgradeSystem:AddAttrModifierSpecial(uWeapon, UpgradeItemID, SpecialUpgradeCfg)
  if not SpecialUpgradeCfg or not next(SpecialUpgradeCfg) then
    return
  end
  local FWeaponAttrModifyData = import("WeaponAttrModifyData")
  local AttrModifyDataArray = slua.Array(UEnums.EPropertyClass.Struct, FWeaponAttrModifyData)
  for _, Cfg in pairs(SpecialUpgradeCfg) do
    local OpFix = Cfg.OP
    local ValueFix = Cfg.Value
    if OpFix == 0 then
    elseif OpFix == 1 then
      ValueFix = ValueFix + 1
    elseif OpFix == 2 then
      OpFix = 0
    elseif OpFix == 3 then
      OpFix = 2
    end
    local AttrModifyData = FWeaponAttrModifyData()
    AttrModifyData.ModifyAttr = Cfg.AttrName
    AttrModifyData.Op = OpFix
    AttrModifyData.ModifyValue = ValueFix
    AttrModifyDataArray:Add(AttrModifyData)
  end
  print(bWriteLog and "WeaponUpgradeSystem:AddAttrModifierSpecial: ", uWeapon, UpgradeItemID, SpecialUpgradeCfg)
  uWeapon:AddWeaponAttrModifierConfig("Equip", AttrModifyDataArray, UpgradeItemID)
  local WeaponOwenr = uWeapon:GetOwnerPawn()
  local OwenrUseWeapon = slua.isValid(WeaponOwenr) and WeaponOwenr:GetCurrentWeapon()
  if OwenrUseWeapon == uWeapon then
    uWeapon:SetWeaponAttrModifierEnable("Equip", false, true)
    uWeapon:SetWeaponAttrModifierEnable("Equip", true, true)
  end
end
function WeaponUpgradeSystem:CheckWeaponUpgradeItem(uOwnerPawn, uWeapon, UpgradeItemID)
  local uWeaponOwner = slua.isValid(uWeapon) and uWeapon:GetOwnerPawn()
  if not slua.isValid(uWeaponOwner) then
    print(bWriteLog and "WeaponUpgradeSystem:HasEnoughUpgradeConsume false, uWepaon or uWepaonOwner is invalid")
    return false
  end
  local WeaponID = uWeapon:GetItemDefineID().TypeSpecificID
  local UpgradeInfoID = uWeapon:GetUpgradeInfoID()
  local AllConsumeItems = self:GetWeaponUpgradeCfg(uWeapon, "ConsumeItems")
  if AllConsumeItems and next(AllConsumeItems) then
    if UpgradeItemID and 0 < UpgradeItemID then
      for _, ConsumeItems in ipairs(AllConsumeItems) do
        for ItemID, Count in pairs(ConsumeItems) do
          if UpgradeItemID == ItemID then
            local CurItemCount = Game:GetItemNumByResID(uOwnerPawn, ItemID)
            if Count <= CurItemCount then
              return true
            else
              print(bWriteLog and string.format("WeaponUpgradeSystem:CheckWeaponUpgradeItem fail: WeaponID=%d UpgradeItemID=%d Item=%d Cur=%d, Need=%d", WeaponID, UpgradeInfoID, ItemID, CurItemCount, Count))
              return false
            end
          end
        end
      end
      return false
    else
      local bCurConsumeItemsEnough = false
      local sCurItemCount = "CurItem="
      for _, ConsumeItems in ipairs(AllConsumeItems) do
        bCurConsumeItemsEnough = true
        for ItemID, Count in pairs(ConsumeItems) do
          local CurItemCount = Game:GetItemNumByResID(uOwnerPawn, ItemID)
          if Count > CurItemCount then
            bCurConsumeItemsEnough = false
            sCurItemCount = string.format("%s(%d-%d)", sCurItemCount, ItemID, CurItemCount)
            break
          end
        end
        if bCurConsumeItemsEnough then
          break
        end
      end
      if not bCurConsumeItemsEnough then
        print(bWriteLog and string.format("WeaponUpgradeSystem:CheckWeaponUpgradeItem fail: WeaponID=%d UpgradeItemID=%d %s", WeaponID, UpgradeInfoID, sCurItemCount))
      end
      return bCurConsumeItemsEnough
    end
  end
  return false
end
function WeaponUpgradeSystem:ConsumeWeaponUpgradeItem(uOwnerPawn, uWeapon, UpgradeItemID)
  if not slua.isValid(uOwnerPawn) then
    return false
  end
  local WeaponID = uWeapon:GetItemDefineID().TypeSpecificID
  local UpgradeInfoID = uWeapon:GetUpgradeInfoID()
  print(bWriteLog and string.format("WeaponUpgradeSystem:ConsumeWeaponUpgradeItem: WeaponID=%d UpgradeItemID=%d", WeaponID, UpgradeItemID or 0))
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local uBackPackComp = USTExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(uOwnerPawn)
  if slua.isValid(uBackPackComp) then
    local AllConsumeItems = self:GetWeaponUpgradeCfg(uWeapon, "ConsumeItems")
    if AllConsumeItems then
      if UpgradeItemID and 0 < UpgradeItemID then
        for _, ConsumeItems in ipairs(AllConsumeItems) do
          local bCurConsumeItemsEnough = false
          for ItemID, Count in pairs(ConsumeItems) do
            if UpgradeItemID == ItemID then
              local ItemDefineID = {}
              ItemDefineID.TypeSpecificID = ItemID
              ItemDefineID.Type = 6
              local ConsumeNum = uBackPackComp:ConsumeItem(ItemDefineID, Count)
              print(bWriteLog and string.format("WeaponUpgradeSystem:ConsumeWeaponUpgradeItem: WeaponID=%d, UpgradeInfoID=%d, Item=%d, WantCost=%d, RealCost=%d", WeaponID, UpgradeInfoID, ItemID, Count, ConsumeNum))
              bCurConsumeItemsEnough = true
              break
            end
          end
          if bCurConsumeItemsEnough then
            break
          end
        end
      else
        for _, ConsumeItems in ipairs(AllConsumeItems) do
          local bCurConsumeItemsEnough = true
          for ItemID, Count in pairs(ConsumeItems) do
            local CurItemCount = Game:GetItemNumByResID(uOwnerPawn, ItemID)
            if Count > CurItemCount then
              bCurConsumeItemsEnough = false
              break
            end
          end
          if bCurConsumeItemsEnough then
            for ItemID, Count in pairs(ConsumeItems) do
              local ItemDefineID = {}
              ItemDefineID.TypeSpecificID = ItemID
              ItemDefineID.Type = 6
              local ConsumeNum = uBackPackComp:ConsumeItem(ItemDefineID, Count)
              print(bWriteLog and string.format("WeaponUpgradeSystem:ConsumeWeaponUpgradeItem: WeaponID=%d, UpgradeInfoID=%d, Item=%d, WantCost=%d, RealCost=%d", WeaponID, UpgradeInfoID, ItemID, Count, ConsumeNum))
            end
            break
          end
        end
      end
    end
  end
end
local TableUtil = require("common.table_util")
function WeaponUpgradeSystem:GetWeaponUpgradeCfg(uWeapon, ConfigKey)
  if not slua.isValid(uWeapon) then
    return nil
  end
  local WeaponID = uWeapon:GetItemDefineID().TypeSpecificID
  local CfgWeaponType = self.bGetWeaponWithNewTypeOrID and uWeapon:GetWeaponTypeNew() or WeaponID
  local UpgradeInfoID = uWeapon:GetUpgradeInfoID()
  local WeaponUpgradeCfg = GamePlayTools.GetCurrentConfig("WeaponUpgradeCfg")
  if WeaponUpgradeCfg then
    local ReturnValue = TableUtil.GetTableValue(WeaponUpgradeCfg.UpgradeCostCfg, CfgWeaponType, UpgradeInfoID + 1, ConfigKey)
    ReturnValue = ReturnValue or TableUtil.GetTableValue(WeaponUpgradeCfg.UpgradeCostCfg, CfgWeaponType, "Common", ConfigKey)
    if ReturnValue then
      return ReturnValue
    end
    print(bWriteLog and string.format("WeaponUpgradeSystem:GetWeaponUpgradeCfg failed. WeaponID=%d WeaponType=%d UpgradeInfoID=%d ConfigKey=%s", WeaponID, CfgWeaponType, UpgradeInfoID, ConfigKey))
  end
  return nil
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, WeaponUpgradeSystem)