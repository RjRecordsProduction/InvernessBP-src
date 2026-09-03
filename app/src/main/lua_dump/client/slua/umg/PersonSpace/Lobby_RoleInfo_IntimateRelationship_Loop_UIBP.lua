local Lobby_RoleInfo_IntimateRelationship_Loop_UIBP = {}
function Lobby_RoleInfo_IntimateRelationship_Loop_UIBP:ctor()
  self.currentExpandMenuIndex = 0
  self.bShowGlowAnim = false
end
function Lobby_RoleInfo_IntimateRelationship_Loop_UIBP:OnInitialize()
  self.LoopScrollGrid_HasBuild = self:InitChildClassScrollBox(self.UIRoot.LoopScrollGrid_HasBuild, "client.slua.umg.PersonSpace.item.Lobby_RoleInfo_IntimateRelationship_Setting_Item01_UIBP")
end
function Lobby_RoleInfo_IntimateRelationship_Loop_UIBP:SetHasBuildData(data)
  printf("Lobby_RoleInfo_IntimateRelationship_Loop_UIBP:SetHasBuildData")
  self.currentExpandMenuIndex = 0
  self.LoopScrollGrid_HasBuild:SetData(data)
end
function Lobby_RoleInfo_IntimateRelationship_Loop_UIBP:ExpandFirstItemMenu()
  printf("Lobby_RoleInfo_IntimateRelationship_Loop_UIBP:ExpandFirstItemMenu")
  local dataSet = self.LoopScrollGrid_HasBuild:GetSetData()
  if dataSet and 0 < #dataSet then
    self.currentExpandMenuIndex = 1
    self.bShowGlowAnim = true
    self.LoopScrollGrid_HasBuild:RefreshItem(1, dataSet[1])
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, Lobby_RoleInfo_IntimateRelationship_Loop_UIBP)