local PANEL = {}
AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "State", "State", FORCE_BOOL)

local non = Color(0, 0, 0, 0)
local black = Color(185, 185, 185, 10)
function PANEL:Init()
    self:SetState(false)
    self:SetText("Placeholder")

    self.margin = Nexus:Scale(10)

    self.Button = self:Add("Nexus:Button")
    self.Button:Dock(LEFT)
    self.Button:SetText("")
    self.Button.Paint = function(s, w, h)
        self.curY = self.curY or 0

        Nexus:DrawRoundedGradient(0, 0, w, h, Nexus.Colors.Primary)
        if self:GetState() then
            self.curY = math.Approach(self.curY, h, FrameTime()*150)
        else
            self.curY = math.Approach(self.curY, 0, FrameTime()*100)
        end

        if Nexus:GetSetting("Nexus-Disable-Animations", false) then
            Nexus:DrawRoundedGradient(0, 0, w, h, self:GetState() and Nexus.Colors.Green or non)
        else
            render.SetScissorRect(0, h-self.curY, w, self.curY, true)
                Nexus:DrawRoundedGradient(0, 0, w, h, Nexus.Colors.Green)
            render.SetScissorRect(0, 0, 0, 0, false)
        end

        draw.SimpleText(s.Text, s:GetFont(), w/2, h/2, s:GetTextColor(), 1, 1)
    
        if s.icon then
            local size = h * 0.5
            local x, y = (w/2) - (size/2)
            Nexus:DrawImgur("1Qx2b5j", x, x, size, size, color_white)
        end
    
        if s:IsHovered() or s.Clicked then
            draw.RoundedBox(s.margin, 0, 0, w, h, black)
        end

        if not self:GetState() then return end
        local size = h*.7
        Nexus:DrawImgur("naCgvmC", w/2 - size/2, h/2 - size/2, size, size, color_white)
    end
    self.Button.DoClick = function(s)
        self:SetState(not self:GetState())
        self:OnStateChanged(self:GetState())
    end
end

function PANEL:PerformLayout(w, h)
    self.Button:SetWide(h)

    if self.AutoWide then
        surface.SetFont(self.font)
        local tw, th = surface.GetTextSize(self:GetText())
        self:SetWide(self.Button:GetWide() + (self:GetText() == "" and 0 or self.margin + tw))
    end
end

function PANEL:OnStateChanged(bool)
end

function PANEL:OnSizeChanged(w, h)
    self.font = Nexus:GetFont(h*.8)
end

function PANEL:GetFont()
    return self.font
end

function PANEL:AutoWide()
    self.AutoWide = true
    self:InvalidateLayout()
end

function PANEL:Paint(w, h)
    draw.SimpleText(self:GetText(), self.font, self.Button:GetWide() + self.margin, h/2, Nexus.Colors.Text, 0, 1)
end
vgui.Register("Nexus:CheckBox", PANEL, "EditablePanel")