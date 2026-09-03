local FriendsListItem_BP = require("client.slua.umg.lobby.FriendList.Item.FriendListItem_Data")
FriendsListItem_BP.ENUM_COMPONENT_TYPE = {
  Relation = 1,
  WowPass = 2,
  Birth = 3,
  Actions = 4,
  InterAction = 5,
  Relation2 = 6,
  Recaller = 7,
  SourceFrom = 8,
  Status = 9,
  Lucky = 10,
  Poke = 11,
  ReturnPlayer = 12,
  Certification = 13,
  LightBoard = 14,
  CollectBadge = 15
}
local CompMapConfig = {
  [FriendsListItem_BP.ENUM_COMPONENT_TYPE.Relation] = {
    root = "CanvasPanel_RelationNew",
    UICfg = UIManager.UI_Config.FriendComp_Relation,
    updataFunc = "SetData",
    needSetInitData = false
  },
  [FriendsListItem_BP.ENUM_COMPONENT_TYPE.WowPass] = {
    root = "CanvasPanel_WowPass",
    UICfg = UIManager.UI_Config.FriendComp_WOWPass
  },
  [FriendsListItem_BP.ENUM_COMPONENT_TYPE.Birth] = {
    root = "Panel_Birthday",
    UICfg = UIManager.UI_Config.FriendComp_Birth
  },
  [FriendsListItem_BP.ENUM_COMPONENT_TYPE.Actions] = {
    root = "HorizontalBox_Actions",
    UICfg = UIManager.UI_Config.FriendComp_ActionBtn
  },
  [FriendsListItem_BP.ENUM_COMPONENT_TYPE.InterAction] = {
    root = "CanvasPanel_Inter",
    UICfg = UIManager.UI_Config.FriendComp_InterAction
  },
  [FriendsListItem_BP.ENUM_COMPONENT_TYPE.Relation2] = {
    root = "CanvasPanel_Relationship",
    UICfg = UIManager.UI_Config.FriendComp_Relation2
  },
  [FriendsListItem_BP.ENUM_COMPONENT_TYPE.Recaller] = {
    root = "CanvasPanel_Recaller",
    UICfg = UIManager.UI_Config.FriendComp_Recaller
  },
  [FriendsListItem_BP.ENUM_COMPONENT_TYPE.SourceFrom] = {
    root = "CanvasPanel_Source",
    UICfg = UIManager.UI_Config.FriendComp_Source
  },
  [FriendsListItem_BP.ENUM_COMPONENT_TYPE.Status] = {
    root = "CanvasPanel_Status",
    UICfg = UIManager.UI_Config.FriendComp_Status
  },
  [FriendsListItem_BP.ENUM_COMPONENT_TYPE.Lucky] = {
    root = "CanvasPanel_Lucky",
    UICfg = UIManager.UI_Config.FriendComp_Lucky
  },
  [FriendsListItem_BP.ENUM_COMPONENT_TYPE.Poke] = {
    root = "CanvasPanel_Poke",
    UICfg = UIManager.UI_Config.FriendComp_Poke
  },
  [FriendsListItem_BP.ENUM_COMPONENT_TYPE.ReturnPlayer] = {
    root = "SizeBox_Return",
    UICfg = UIManager.UI_Config.ReturnActivity_Player_Tag_Item,
    updataFunc = "SetData",
    needSetInitData = false
  },
  [FriendsListItem_BP.ENUM_COMPONENT_TYPE.Certification] = {
    root = "CanvasPanel_Certification",
    BpPath = "/Game/UMG/UI_BP/Common/Common_Certification_UIBP.Common_Certification_UIBP",
    updataFunc = "SetAuthInfo",
    needSetInitData = true,
    needUnPack = true
  },
  [FriendsListItem_BP.ENUM_COMPONENT_TYPE.LightBoard] = {
    root = "ScaleBox_LightBoard",
    BpPath = "/Game/UMG/UI_BP/Common/Common_LightBoard_UIBP.Common_LightBoard_UIBP",
    updataFunc = "ShowLightBoard",
    needSetInitData = true,
    needUnPack = true
  },
  [FriendsListItem_BP.ENUM_COMPONENT_TYPE.CollectBadge] = {
    root = "SizeBox_CollectLevelItem",
    BpPath = "/Game/UMG/UI_Logic/Common/CommonItem/Common_Collect_Level_DynamicLoading_UIBP.Common_Collect_Level_DynamicLoading_UIBP",
    updataFunc = "InitCollectBadge",
    needSetInitData = true,
    needUnPack = true
  }
}
function FriendsListItem_BP:SetCompChild(compEnumType, bIsShow, tbCompData)
  if not compEnumType then
    log_error("FriendsListItem_BP:SetCompChild for nil type")
    return
  end
  local compCfg = CompMapConfig[compEnumType]
  if not compCfg then
    log_error(string.format("FriendsListItem_BP:SetCompChild for nil config, type = %s", compEnumType))
    return
  end
  if not self.UIRoot or not self.UIRoot[compCfg.root] then
    log_error(string.format("FriendsListItem_BP:SetCompChild find no root for type = %s", compEnumType))
    return
  end
  if not bIsShow then
    self:SetWidgetVisible(self.UIRoot[compCfg.root], false)
    return
  end
  self:SetWidgetVisible(self.UIRoot[compCfg.root], true)
  self._CompUIMap = self._CompUIMap or {}
  local compUI = self._CompUIMap[compEnumType]
  if not compUI then
    compUI = self:OnlyCreateCompChild(compEnumType, tbCompData)
    self._CompUIMap[compEnumType] = compUI
  end
  if not compUI then
    log_error(string.format("FriendsListItem_BP:SetCompChild create child failed for type = %s", compEnumType))
    return
  end
  local funcName = compCfg.updataFunc or "SetData"
  local func
  local obj = compUI
  if compCfg.UICfg then
    func = compUI[funcName]
  elseif compCfg.BpPath then
    obj = compUI.UIRoot
    func = obj[funcName]
  end
  if not func then
    log_error(string.format("FriendsListItem_BP:SetCompChild no func for type = %s", compEnumType))
    return
  end
  local status, err = pcall(function()
    if compCfg.needUnPack then
      func(obj, table.unpack(tbCompData))
    else
      func(obj, tbCompData)
    end
  end)
  if not status then
    log_error_format("[FriendsListItem_BP]SetCompChild error: %s strName: %s", err, compEnumType)
  end
end
function FriendsListItem_BP:OnlyCreateCompChild(compEnumType, tbCompData)
  local compCfg = CompMapConfig[compEnumType]
  if not compCfg then
    return nil
  end
  if not self.UIRoot or not self.UIRoot[compCfg.root] then
    return nil
  end
  local child
  if compCfg.UICfg then
    child = self:CreateChildWindow(compCfg.root, compCfg.UICfg, tbCompData)
    child:SetAutoSize(true)
  elseif compCfg.BpPath then
    child = self:CreateChildWindowWithBpPath(self.UIRoot[compCfg.root], nil, compCfg.BpPath)
    child:SetAutoSize(true)
  end
  return child
end