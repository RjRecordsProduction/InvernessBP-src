local splash_screen_ani_ui = {}
function splash_screen_ani_ui:ctor(selfType, aniFinishCallback)
  log(bWriteLog and "splash_screen_ani_ui:ctor")
  if not aniFinishCallback then
    log_warning("splash_screen_ani_ui:ctor, aniFinishCallback is nil")
  end
  self.end
function splash_screen_ani_ui:OnPostInitialize()
  if self.UIRoot.animation then
    log(bWriteLog and WriteLog and "splash_screen_ani_ui:OnPostInitialize, animation is not nil, add animation event and play animation")
    self:AddControlEventByControl(self.UIRoot.animation, "OnAnimationFinished", self.OnAnimationFinished, self)
    self.UIRoot:PlayUserWidgetAnimation(self.UIRoot.animation, 0, 1, 0, 1)
  else
    log(bWriteLog and "splash_screen_ani_ui:OnPostInitialize, animation is nil, call aniFinishCallback directly")
    self:_CallFinishCallback()
  end
  local cr = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if cr == PublishRegionMacros.JAPAN then
    self:InitJP()
  end
end
function splash_screen_ani_ui:InitJP()
  local TextBlock_Word = self.UIRoot.TextBlock_Word
  if TextBlock_Word then
    local word = "\227\129\147\227\129\174\227\130\162\227\131\151\227\131\170\227\129\175\229\159\186\230\156\172\231\132\161\230\150\153\227\129\167\233\129\138\227\129\185\227\129\190\227\129\153\227\129\140\227\128\129\n\228\184\128\233\131\168\230\156\137\230\150\153\227\130\162\227\130\164\227\131\134\227\131\160\227\129\140\227\129\148\227\129\150\227\129\132\227\129\190\227\129\153\227\128\130\n\230\156\170\230\136\144\229\185\180\227\129\174\230\150\185\227\129\140\230\156\137\230\150\153\227\130\162\227\130\164\227\131\134\227\131\160\227\130\146\232\179\188\229\133\165\227\129\153\227\130\139\233\154\155\227\129\175\n\228\191\157\232\173\183\232\128\133\227\129\174\232\168\177\229\143\175\227\130\146\227\130\130\227\130\137\227\129\134\227\129\139\n\228\184\128\231\183\146\227\129\171\232\179\188\229\133\165\227\129\153\227\130\139\227\130\136\227\129\134\227\129\171\227\129\151\227\129\166\227\129\143\227\129\160\227\129\149\227\129\132\227\128\130"
    TextBlock_Word:SetText(word)
  end
end
function splash_screen_ani_ui:OnClose()
  splash_screen_ani_ui.__super.OnClose(self)
  self.aniFinishCallback = nil
end
function splash_screen_ani_ui:_CallFinishCallback()
  log(bWriteLog and "splash_screen_ani_ui:_CallFinishCallback")
  if self.aniFinishCallback then
    self.aniFinishCallback()
  else
    log_warning("splash_screen_ani_ui:_CallFinishCallback aniFinishCallback is nil")
  end
end
function splash_screen_ani_ui:OnAnimationFinished()
  log(bWriteLog and "splash_screen_ani_ui:OnAnimationFinished")
  self:_CallFinishCallback()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local Csplash_screen_ani_ui = class(ui_base, nil, splash_screen_ani_ui)
return Csplash_screen_ani_ui