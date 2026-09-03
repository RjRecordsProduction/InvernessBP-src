local collect_guide_cfg = {
  TitleID = 77546,
  BPPath = "/Game/UMG/UI_BP/Common/Popup/Theme/Item/Common_Popup_Theme_Explain_Picture02_Item_UIBP.Common_Popup_Theme_Explain_Picture02_Item_UIBP",
  RefreshFun = function(node_root)
    if not node_root then
      return
    end
    local Util = require("client.slua_ui_framework.util")
    Util.SetTexture(node_root.Image_Pic_1, "/Game/Mod/Lobby/Split/Collect/Texture/Collect_Beginner_left.Collect_Beginner_left")
    Util.SetTexture(node_root.Image_Pic_2, "/Game/Mod/Lobby/Split/Collect/Texture/Collect_Beginner_Right.Collect_Beginner_Right")
    node_root.Text_Pic_1:SetText(LocUtil.LocalizeResFormat(77547))
    node_root.Text_Pic_2:SetText(LocUtil.LocalizeResFormat(77548))
  end
}
return collect_guide_cfg