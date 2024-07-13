local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:Scale(6)
    self.curBarPos = 0

    self.Buttons = {}
    self.ButtonDirect = {}

    self.lerp = 0
    self:SetTall(Nexus:Scale(60))
end

local col_zero = Color(0, 0, 0, 0)
function PANEL:AddItem(str, func)
    func = func or function() end

    local button = self:Add("Nexus:Button")
    button:Dock(LEFT)
    button:DockMargin(0, 0, 0, self.margin)
    button.OnSelected = func
    button.str = str
    button.DoClick = function(s)
        self:SelectItem(str)
    end
    button.Paint = function(s, w, h)
        surface.SetDrawColor((s:IsHovered() or self.Selected == str) and Nexus:OffsetColor(Nexus.Colors.Header, 20) or col_zero)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText(str, Nexus:GetFont(h*.7), w/2, h/2, Nexus.Colors.Text, 1, 1)
    end

    table.insert(self.Buttons, button)
    self.ButtonDirect[str] = #self.Buttons
end

function PANEL:SelectItem(str)
    for _, v in ipairs(self.Buttons) do
        if str == v.str then
            self.Selected = str
            v.OnSelected()

            self.lerp = 0
            break
        end
    end
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(Nexus.Colors.Header)
    surface.DrawRect(0, 0, w, h)

    local wide = math.floor(w/#self.Buttons)
    self.lerp = math.min(self.lerp + .8 * FrameTime(), 1)
    self.curBarPos = LerpVector(self.lerp, Vector(self.curBarPos, 0, 0), Vector((self.ButtonDirect[self.Selected]-1)*wide, 0, 0))
    local x, y = math.floor(self.curBarPos.x), h - self.margin

    draw.RoundedBox(self.margin, x, y, wide, self.margin, Nexus.Colors.Primary)
end

function PANEL:PerformLayout(w, h)
    local wide = math.floor(w/#self.Buttons)
    for _, v in ipairs(self.Buttons) do
        v:SetWide(wide)
    end
end
vgui.Register("Nexus:Navbar", PANEL, "EditablePanel")