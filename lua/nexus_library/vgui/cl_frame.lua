local gradient = Material("vgui/gradient-d")
local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:Scale(10)

    self.Header = self:Add("DPanel")
    self.Header:Dock(TOP)
    self.Header:SetTall(Nexus:Scale(55))
    self.Header.Paint = function(s, w, h)
        draw.RoundedBoxEx(self.NoRound and 0 or self.margin, 0, 0, w, h, Nexus.Colors.Header, true, true)
        draw.SimpleText(self.Title or "", Nexus:GetFont(h*.8), self.margin*2, h/2, Nexus.Colors.Text, 0, 1)
    end
    self.Header.PerformLayout = function(s, w, h)
        local width, height = Nexus:Scale(100), h*.7
        self.Header.CloseButton:SetSize(height, height)
        self.Header.CloseButton:SetPos(w - height - self.margin, (h/2) - (height/2))
    end

    self.Header.CloseButton = self.Header:Add("Nexus:Button")
    self.Header.CloseButton:SetText("")
    self.Header.CloseButton.PaintOver = function(s, w, h)
        local size = h * 0.5
        local x, y = (w - size) / 2, (h - size) / 2
        Nexus:DrawImgur("TeAqVnQ", x, y, size, size, Color(207, 207, 207))
        if s:IsHovered() then
            Nexus:DrawImgur("TeAqVnQ", x, y, size, size, Color(0, 0, 0, 100))
        end
    end
    self.Header.CloseButton.DoClick = function()
        self:Remove()
    end
end

function PANEL:SetTitle(str)
    self.Title = str
end

function PANEL:HideCloseButton()
    self.Header.CloseButton:Hide()
end

function PANEL:SetNoRound()
    self.NoRound = true
end

function PANEL:Paint(w, h)
    local headerTall = self.Header:GetTall()/2
    draw.RoundedBox(self.NoRound and 0 or self.margin, 0, headerTall, w, h-headerTall, Nexus.Colors.Background)
end
vgui.Register("Nexus:Frame", PANEL, "EditablePanel")