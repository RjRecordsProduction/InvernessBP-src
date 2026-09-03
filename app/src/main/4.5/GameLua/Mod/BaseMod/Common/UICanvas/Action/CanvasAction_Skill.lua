local CanvasAction_Skill = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local delegate_container = require("common.delegate_container")
function CanvasAction_Skill:ctor(selfType, CanvasProxy, tConfig, Index)
  self.HideCount = 0
end
function CanvasAction_Skill:BindEvent()
  if not self.Config.Hide then
    return
  end
  self.DelegateContainer = delegate_container()
  local SuperData = GameplayData.GetSuperData()
  self.DelegateContainer:AddDataListener(SuperData, "CharacterDataReady", function()
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(uPlayerCharacter) then
      self:OnSkillUpdate(uPlayerCharacter)
      self:AddControlEvent(uPlayerCharacter, "OnHandleSkillStartDelegate", self.OnSkillStart, self)
      self:AddControlEvent(uPlayerCharacter, "OnHandleSkillEndDelegate", self.OnSkillEnd, self)
    end
  end)
end
function CanvasAction_Skill:UnbindEvent()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    self:RemoveControlEvent(uPlayerCharacter, "OnHandleSkillStartDelegate")
    self:RemoveControlEvent(uPlayerCharacter, "OnHandleSkillEndDelegate")
  end
  if self.DelegateContainer then
    self.DelegateContainer:Dispose()
    self.DelegateContainer = nil
  end
end
function CanvasAction_Skill:UpdateCanvasShow()
  local bNewIsShow = self.HideCount == 0
  if self.bIsShow ~= bNewIsShow then
    self.bIsShow = bNewIsShow
    CanvasAction_Skill.__super.UpdateCanvasShow(self)
  end
end
function CanvasAction_Skill:OnSkillUpdate(uCharacter)
  if slua.isValid(uCharacter) and slua.isValid(uCharacter.SkillManager) then
    self.HideCount = 0
    local SkillIDs = uCharacter.SkillManager:GetCurAllSkillIDs()
    for _, SkillID in pairs(SkillIDs) do
      local bNeedHide = self:HasValue(self.Config.Hide, SkillID)
      if bNeedHide then
        self.HideCount = self.HideCount + 1
        if self.bNeedWriteLog then
          print(bWriteLog and string.format("CanvasAction_Skill:OnSkillUpdate SkillID:%d, HideCount:%d, from:%s", SkillID, self.HideCount, self.CanvasProxy and self.CanvasProxy.CanvasPanel))
        end
      end
    end
    self:UpdateCanvasShow()
  end
end
function CanvasAction_Skill:OnSkillStart(uCharacter, InSkillID)
  local bNeedHide = self:HasValue(self.Config.Hide, InSkillID)
  if bNeedHide then
    self.HideCount = self.HideCount + 1
    self:UpdateCanvasShow()
    if self.bNeedWriteLog then
      print(bWriteLog and string.format("CanvasAction_Skill:OnSkillStart SkillID:%d, HideCount:%d, from:%s", InSkillID, self.HideCount, self.CanvasProxy and self.CanvasProxy.CanvasPanel))
    end
  end
end
function CanvasAction_Skill:OnSkillEnd(uCharacter, Reason, InSkillID)
  local bNeedHide = self:HasValue(self.Config.Hide, InSkillID)
  if bNeedHide then
    self.HideCount = self.HideCount - 1
    self:UpdateCanvasShow()
    if self.bNeedWriteLog then
      print(bWriteLog and string.format("CanvasAction_Skill:OnSkillEnd SkillID:%d, HideCount:%d, from:%s", InSkillID, self.HideCount, self.CanvasProxy and self.CanvasProxy.CanvasPanel))
    end
  end
end
local class = require("class")
local CanvasActionBase = require("GameLua.Mod.BaseMod.Common.UICanvas.Action.CanvasActionBase")
local CCanvasAction_Skill = class(CanvasActionBase, nil, CanvasAction_Skill)
return CCanvasAction_Skill