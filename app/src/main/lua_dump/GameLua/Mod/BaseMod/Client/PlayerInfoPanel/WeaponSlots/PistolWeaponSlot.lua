local PistolWeaponSlot = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local WeaponSlotsConfig = require("GameLua.Mod.BaseMod.Client.PlayerInfoPanel.WeaponSlots.WeaponSlotsConfig")
function PistolWeaponSlot:UpdateSlotUnSelectedIcon()
end
local class = require("class")
local UILuaUserWidget = require("GameLua.Mod.BaseMod.Common.UI.UILuaUserWidget")
return class(UILuaUserWidget, nil, PistolWeaponSlot)