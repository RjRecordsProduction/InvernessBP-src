local Common_Title_UIBP = {}
local GlobalRankID = 100001
function Common_Title_UIBP:OnPostInitialize()
  self:RestoreUIOperation()
end
function Common_Title_UIBP:_SetLbsGlobalAliasInfo(RankID)
  if RankID ~= GlobalRankID then
    return
  end
  self:SetTexture(self.UIRoot.Image_bk, "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_zuigaoji_png.LOBBY_image_zuigaoji_png")
  self:SetTexture(self.UIRoot.icon, "/Game/Arts/UI/TableIcons/Title_Icon/Title_icon_quanqiu_64.Title_icon_quanqiu_64")
  self:SetWidgetVisible(self.UIRoot.icon, true, false)
  self:SetWidgetVisible(self.UIRoot.icon_nation, false, false)
end
function Common_Title_UIBP:_GetNationInfo(Nation)
  local cfg = CDataTable.GetTableData("RegionConfig", Nation)
  cfg = cfg or CDataTable.GetTableData("RegionConfig", "G1")
  return cfg.res_path
end
function Common_Title_UIBP:_SetDynamicBG(DynamicIconPath)
  self._childUI = self:CreateChildWindowWithBpPath(self.UIRoot.DynamicIcon_Root, UIManager.UI_Config.Lobby_RoleInfo_EffectSkin_Item_UIBP, DynamicIconPath)
end
function Common_Title_UIBP:_SetAliasData(AliasID, Nation, Quality, PathUrl, Title, AvailableLen, RankID, DynamicIconPath, FinishedProduct)
  self:_ReleaseChildUI()
  if FinishedProduct == 1 then
    self:_FinishedProduct(AliasID, DynamicIconPath, Title)
    return
  end
  self:_SetWeaponStrengthRankInfo(AliasID)
  self:SetWidgetVisible(self.UIRoot.Image_bk, true, false)
  self:SetWidgetVisible(self.UIRoot.icon, true, false)
  self:SetWidgetVisible(self.UIRoot.title, true, false)
  if Nation and Nation ~= "" then
    self:SetWidgetVisible(self.UIRoot.icon_nation, true, false)
    self:SetWidgetVisible(self.UIRoot.icon, false, false)
    local ResPath = self:_GetNationInfo(Nation)
    self:SetTexture(self.UIRoot.icon_nation, ResPath)
  else
    self:SetWidgetVisible(self.UIRoot.icon_nation, false, false)
    self:SetWidgetVisible(self.UIRoot.icon, true, false)
    self:SetTexture(self.UIRoot.icon, PathUrl)
  end
  self:SetWidgetVisible(self.UIRoot.Image_bk, false, false)
  self.UIRoot.title:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
  self.UIRoot.title:SetText(Title)
  if RankID ~= GlobalRankID and DynamicIconPath ~= "" then
    self:_SetDynamicBG(DynamicIconPath)
  end
  if Quality == 0 then
    self:SetTexture(self.UIRoot.Image_bk, "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao4_png.LOBBY_image_chenghao4_png")
  elseif Quality == 1 then
    self:SetTexture(self.UIRoot.Image_bk, "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao3_png.LOBBY_image_chenghao3_png")
  elseif Quality == 2 then
    self:SetTexture(self.UIRoot.Image_bk, "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao_png.LOBBY_image_chenghao_png")
  elseif Quality == 3 then
    self:SetTexture(self.UIRoot.Image_bk, "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao1_png.LOBBY_image_chenghao1_png")
  elseif Quality == 4 then
    self:SetTexture(self.UIRoot.Image_bk, "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao2_png.LOBBY_image_chenghao2_png")
  elseif Quality == 5 then
    self:SetTexture(self.UIRoot.Image_bk, "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_zuigaoji_png.LOBBY_image_zuigaoji_png")
  elseif Quality == 6 then
    self:SetTexture(self.UIRoot.Image_bk, "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao6_png.LOBBY_image_chenghao6_png")
    self.UIRoot.title:SetColorAndOpacity(FSlateColor(FLinearColor(1.0, 0.572549, 0.572549, 1)))
  end
  self:SetWidgetVisible(self.UIRoot.Image_bk, true, false)
  self:_SetLbsGlobalAliasInfo(RankID)
end
function Common_Title_UIBP:_ReleaseChildUI()
  if self._childUI then
    self._childUI:Close()
    self._childUI = nil
  end
end
function Common_Title_UIBP:_FinishedProduct(AliasID, bpPatch, title)
  log(bWriteLog and string.format("Common_Title_UIBP:_FinishedProduct. bpPatch=%s, title=%s", tostring(bpPatch), tostring(title)))
  self:SetWidgetVisible(self.UIRoot.Image_bk, false, false)
  self:SetWidgetVisible(self.UIRoot.icon, false, false)
  self:SetWidgetVisible(self.UIRoot.title, false, false)
  self:SetWidgetVisible(self.UIRoot.icon_nation, false, false)
  self._childUI = self:CreateChildWindowWithBpPath(self.UIRoot.DynamicIcon_Root, UIManager.UI_Config.Lobby_RoleInfo_EffectSkin_Item_UIBP, bpPatch, "Fadein", {
    bPlayOnce = true,
    finishAniCallback = function()
      self:_SetWeaponStrengthRankInfo(AliasID)
    end
  })
  local showAlias = AliasID
  if self._childUI and self._childUI.UIRoot.Fadein then
    showAlias = 0
  end
  self:_SetWeaponStrengthRankInfo(showAlias)
  self._childUI.UIRoot.title:SetText(title)
end
function Common_Title_UIBP:_SetWeaponStrengthRankInfo(AliasID)
  local cfg = CDataTable.GetTableData("AliasCfg", AliasID)
  local rank
  if cfg and cfg.AliasType == 7 then
    local RoleInfoSystem = require("client.slua.logic.roleInfo.logic_roleinfo_title")
    local aliasInfo = RoleInfoSystem.alias_list_info[AliasID]
    if aliasInfo then
      rank = aliasInfo.rank
    end
  end
  self:SetWidgetVisible(self.UIRoot.ScaleBox_Rank, rank ~= nil, false)
  if rank then
    self.UIRoot.TextBlock_Rank:SetText(rank)
  end
end
function Common_Title_UIBP:SetAliasInfo(AliasID, Title, Nation, AvailableLen, RankID)
  self:UIOperation(function()
    local cfg = CDataTable.GetTableData("AliasCfg", AliasID)
    if not cfg then
      return
    end
    self:_SetAliasData(AliasID, Nation, cfg.AliasQuality, cfg.AliasIconPathSmall, Title, AvailableLen, RankID, cfg.DynamicTitlePath, cfg.FinishedProduct)
  end)
end
local class = require("class")
local ui_base = require("client.slua.component.item.ItemChildren.CommonItem_UIBase")
local CCommon_ComboBox_UIBP = class(ui_base, nil, Common_Title_UIBP)
return CCommon_ComboBox_UIBP