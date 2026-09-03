local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
local UI_RoleInfo_Base = {}
function UI_RoleInfo_Base:ctor()
end
function UI_RoleInfo_Base:OnClose()
  self:ResetData()
  UI_RoleInfo_Base.__super.OnClose(self)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUI_RoleInfo_Base = class(ui_base, nil, UI_RoleInfo_Base)
return CUI_RoleInfo_Base