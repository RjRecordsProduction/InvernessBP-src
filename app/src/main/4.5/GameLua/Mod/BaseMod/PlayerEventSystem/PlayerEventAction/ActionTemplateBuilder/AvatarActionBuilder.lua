local AvatarActionBuilder = {}
function AvatarActionBuilder:Init(bClient)
  AvatarActionBuilder.__super.Init(self, bClient)
end
function AvatarActionBuilder:Clear()
end
function AvatarActionBuilder:BuildActionTemplate(eventID, targetCharacter, actionDataTable)
  if eventID == EVENTID_PLAYEREVENT_AVATAR_LOGIC_EQUIPPED then
    return self:CreateLogicAvatarActionArray(actionDataTable.nSlotID, actionDataTable.tActionData)
  end
  if eventID == EVENTID_PLAYEREVENT_AVATAR_MESH_EQUIPPED then
    return self:CreateMeshAvatarActionArray(actionDataTable.nSlotID, actionDataTable.tActionData)
  end
end
function AvatarActionBuilder:CreateLogicAvatarActionArray(nSlotID, tActionData)
  local actionArray = {}
  local additionAvatarAction = self:GetAdditonAvatarAction(nSlotID, tActionData.AdditionAvatarID)
  if additionAvatarAction then
    actionArray[#actionArray + 1] = additionAvatarAction
  end
  local execObjectAction = self:GetExecObjectAction(tActionData.ExecObjectPath)
  if execObjectAction then
    actionArray[#actionArray + 1] = execObjectAction
  end
  local execLuaFileAction = self:GetExecLuaFileAction(tActionData.ExecLuaFilePath)
  if execLuaFileAction then
    actionArray[#actionArray + 1] = execLuaFileAction
  end
  return actionArray
end
function AvatarActionBuilder:CreateMeshAvatarActionArray(nSlotID, tActionData)
  local actionArray = {}
  local execObjectPath = self:GetExecObjectAction(tActionData.ExecObjectPath)
  if execObjectPath then
    actionArray[#actionArray + 1] = execObjectPath
  end
  local execLuaFileAction = self:GetExecLuaFileAction(tActionData.ExecLuaFilePath)
  if execLuaFileAction then
    actionArray[#actionArray + 1] = execLuaFileAction
  end
  return actionArray
end
function AvatarActionBuilder:GetAdditonAvatarAction(nSlotID, nAdditionAvatarID)
  if nAdditionAvatarID == nil or nAdditionAvatarID <= 0 then
    return nil
  end
  local additionAvatarAction = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Action.AdditionAvatarAction")
  local NewAdditionAvatarAction = additionAvatarAction()
  NewAdditionAvatarAction:Init(self.bIsClient, nAdditionAvatarID, nSlotID)
  return NewAdditionAvatarAction
end
function AvatarActionBuilder:IsActionDataEqual(actionDataTable1, actionDataTable2)
  if not actionDataTable1 and not actionDataTable2 then
    return true
  end
  if not actionDataTable1 or not actionDataTable2 then
    return false
  end
  if actionDataTable1.nItemID == actionDataTable2.nItemID and actionDataTable1.nSlotID == actionDataTable2.nSlotID then
    return true
  end
  return false
end
local class = require("class")
local CBuilderBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.ActionTemplateBuilder.ActionBuilderBase")
local CAvatarActionBuilder = class(CBuilderBase, nil, AvatarActionBuilder)
return CAvatarActionBuilder