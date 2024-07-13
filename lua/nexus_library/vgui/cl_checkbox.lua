local PANEL = {}
AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "State", "State", FORCE_BOOL)
function PANEL:Init()
    self:SetState(false)
    self:SetText("Placeholder")

    self.Button = self:Add("Nexus:Button")
    self.Button:Dock(RIGHT)
    self.Button:SetText("")
    self.Button.PaintOver = function(s, w, h)
        if not self:GetState() then return end
        local size = h*.7
        Nexus:DrawImgur("naCgvmC", w/2 - size/2, h/2 - size/2, size, size, Nexus.Colors.Green)
    end
    self.Button.DoClick = function()
        surface.PlaySound("buttons/button15.wav")
        self:SetState(not self:GetState())
        self:OnStateChanged(self:GetState())
    end
end

function PANEL:PerformLayout(w, h)
    self.Button:SetWide(h)
end

function PANEL:OnStateChanged(bool)
end

function PANEL:Paint(w, h)
    draw.SimpleText(self:GetText(), Nexus:GetFont(h), 0, h/2, Color(209, 209, 209), 0, 1)
end
vgui.Register("Nexus:CheckBox", PANEL, "EditablePanel")