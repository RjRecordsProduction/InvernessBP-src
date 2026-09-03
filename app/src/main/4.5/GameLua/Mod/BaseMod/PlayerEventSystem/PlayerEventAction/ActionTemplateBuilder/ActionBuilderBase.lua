local ActionBaseTemplate = {}
local PlayerEventTool = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventTool")
function ActionBaseTemplate:ctor()
  self.bIsClient = false
end
function ActionBaseTemplate:Init(bClient)
  self.bIsClient = bClient
end
function ActionBaseTemplate:Clear()
end
function ActionBaseTemplate:BuildActionTemplate(eventID, targetCharacter, actionDataTable)
  return nil
end
function ActionBaseTemplate:IsActionDataEqual(actionDataTable1, actionDataTable2)
  return false
end
function ActionBaseTemplate:CreatePlayerActionArray(tActionData, tParam, uOwnerCharacter)
  if not tActionData then
    return nil
  end
  local actionArray = {}
  local InsertActionArray = function(Action)
    actionArray[#actionArray + 1] = Action
    Action:SetOwner(uOwnerCharacter)
  end
  local modifyDatas = PlayerEventTool.DecodeModifyActionData(tActionData.ModifyAttrs, tParam)
  if modifyDatas then
    for index, value in ipairs(modifyDatas) do
      local modityAction = self:GetModifyAttrAction(value)
      if modityAction then
        InsertActionArray(modityAction)
      end
    end
  end
  local buffAction = self:GetBuffAction(tActionData.BufffInstIDs_a, false, tParam)
  if buffAction then
    InsertActionArray(buffAction)
  end
  local VictimBuffAction = self:GetBuffAction(tActionData.VictimBufffInstIDs_a, true, tParam)
  if VictimBuffAction then
    InsertActionArray(VictimBuffAction)
  end
  local skillAction = self:GetSkillAction(tActionData.SkillID)
  if skillAction then
    InsertActionArray(skillAction)
  end
  local activeSkillActoion = self:GetActiveSkillAction(tActionData.ActiveSkillIDs_a, true)
  if activeSkillActoion then
    InsertActionArray(activeSkillActoion)
  end
  local noActiveSkillActoion = self:GetActiveSkillAction(tActionData.NoActiveSkillIDs_a, false)
  if noActiveSkillActoion then
    InsertActionArray(noActiveSkillActoion)
  end
  local InactiveSkillActoion = self:GetInactiveSkillAction(tActionData.InactiveSkillIDs_a, false)
  if InactiveSkillActoion then
    InsertActionArray(InactiveSkillActoion)
  end
  local replaceSkillActoion = self:GetReplaceSkillAction(tActionData.OldSkillIDs_a, tActionData.NewSkillIDs_a)
  if replaceSkillActoion then
    InsertActionArray(replaceSkillActoion)
  end
  local AddSkillAction = self:AddSkillAction(tActionData.AddSkillIDs_a)
  if AddSkillAction then
    InsertActionArray(AddSkillAction)
  end
  local itemAction = self:GetAddItemAction(tActionData.Items_a, tActionData.ItemCounts_a)
  if itemAction then
    InsertActionArray(itemAction)
  end
  local skillTokenAction = self:GetSkillTokenAction(tActionData.AddSkillTokenIDs_a)
  if skillTokenAction then
    InsertActionArray(skillTokenAction)
  end
  local execObjectAction = self:GetExecObjectAction(tActionData.ExecObjectPath)
  if execObjectAction then
    InsertActionArray(execObjectAction)
  end
  local execLuaFileAction = self:GetExecLuaFileAction(tActionData.ExecLuaFilePath, tParam)
  if execLuaFileAction then
    InsertActionArray(execLuaFileAction)
  end
  local skillLimitAction = self:GetSkillLimitAction(tActionData.LimitSkillIDs_a)
  if skillLimitAction then
    InsertActionArray(skillLimitAction)
  end
  return actionArray
end
function ActionBaseTemplate:IsStringEmpty(Str)
  if Str == nil or Str == "" then
    return true
  end
  return false
end
function ActionBaseTemplate:GetModifyAttrAction(DynamicModifyItem)
  if not DynamicModifyItem then
    return nil
  end
  local attrAction = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Action.AttrModifyAction")
  local NewAttrAction = attrAction()
  NewAttrAction:Init(self.bIsClient, DynamicModifyItem)
  return NewAttrAction
end
function ActionBaseTemplate:GetBuffAction(buffInstIDs, bVictim, tParam)
  if buffInstIDs == nil or buffInstIDs:Num() < 1 then
    return nil
  end
  local buffAction = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Action.AddBuffAction")
  local buffData = {buffSkillIDs_a = buffInstIDs, layerCount = 1}
  local NewBuffAction = buffAction()
  NewBuffAction:Init(self.bIsClient, buffData, bVictim)
  return NewBuffAction
end
function ActionBaseTemplate:GetSkillAction(skillID)
  if skillID == nil or skillID <= 0 then
    return nil
  end
  local skillAction = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Action.TriggerSkillAction")
  local NewSkillAction = skillAction()
  NewSkillAction:Init(self.bIsClient, skillID)
  return NewSkillAction
end
function ActionBaseTemplate:GetActiveSkillAction(ActiveSkillIDs, bActive)
  if ActiveSkillIDs == nil or ActiveSkillIDs:Num() < 1 then
    return nil
  end
  local skillAction = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Action.ActiveSkillAction")
  local NewSkillAction = skillAction()
  NewSkillAction:Init(self.bIsClient, ActiveSkillIDs, bActive)
  return NewSkillAction
end
function ActionBaseTemplate:GetInactiveSkillAction(InactiveSkillIDs, bActive)
  if InactiveSkillIDs == nil or InactiveSkillIDs:Num() < 1 then
    return nil
  end
  local SkillAction = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Action.InactiveSkillAction")
  local InactiveSkillAction = SkillAction()
  InactiveSkillAction:Init(self.bIsClient, InactiveSkillIDs, bActive)
  return InactiveSkillAction
end
function ActionBaseTemplate:AddSkillAction(AddSkillIDs)
  if AddSkillIDs == nil or AddSkillIDs:Num() < 1 then
    return nil
  end
  local CAddSkillAction = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Action.AddSkillAction")
  local NewAddSkillAction = CAddSkillAction()
  NewAddSkillAction:Init(self.bIsClient, AddSkillIDs)
  return NewAddSkillAction
end
function ActionBaseTemplate:GetReplaceSkillAction(OldSkillIDs, NewSkillIDs)
  if OldSkillIDs == nil or OldSkillIDs:Num() < 1 or NewSkillIDs == nil or NewSkillIDs:Num() < 1 then
    return nil
  end
  local skillAction = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Action.ReplaceSkillAction")
  local NewSkillAction = skillAction()
  NewSkillAction:Init(self.bIsClient, OldSkillIDs, NewSkillIDs)
  return NewSkillAction
end
function ActionBaseTemplate:GetAddItemAction(ItemIDs, ItemCounts)
  if ItemIDs == nil or ItemIDs:Num() < 1 then
    return nil
  end
  local itemAction = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Action.AddItemAction")
  local NewItemAction = itemAction()
  NewItemAction:Init(self.bIsClient, ItemIDs, ItemCounts)
  return NewItemAction
end
function ActionBaseTemplate:GetSkillTokenAction(SkillIDs)
  if SkillIDs == nil or SkillIDs:Num() < 1 then
    return nil
  end
  local TokenAction = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Action.AddSkillToken")
  local NewTokenAction = TokenAction()
  NewTokenAction:Init(self.bIsClient, SkillIDs)
  return NewTokenAction
end
function ActionBaseTemplate:GetExecObjectAction(sExecObjectPath)
  if sExecObjectPath == nil or sExecObjectPath == "" then
    return nil
  end
  local execObjectAction = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Action.ExecObjectAction")
  local NewExecObjectAction = execObjectAction()
  NewExecObjectAction:Init(self.bIsClient, sExecObjectPath)
  return NewExecObjectAction
end
function ActionBaseTemplate:GetExecLuaFileAction(sExecLuaFilePath, tParam)
  if sExecLuaFilePath == nil or sExecLuaFilePath == "" then
    return nil
  end
  local execLuaFileAction = require(sExecLuaFilePath)
  if execLuaFileAction == nil then
    return nil
  end
  local NewExecLuaFileAction = execLuaFileAction()
  NewExecLuaFileAction:Init(self.bIsClient, tParam)
  return NewExecLuaFileAction
end
function ActionBaseTemplate:GetSkillLimitAction(SkillIDs)
  if SkillIDs == nil or SkillIDs:Num() < 1 then
    return nil
  end
  local LimitAction = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Action.LimitSkillAction")
  local NewLimitAction = LimitAction()
  NewLimitAction:Init(self.bIsClient, SkillIDs)
  return NewLimitAction
end
local class = require("class")
local object = require("object")
local CActionBaseTemplate = class(object, nil, ActionBaseTemplate)
return CActionBaseTemplate