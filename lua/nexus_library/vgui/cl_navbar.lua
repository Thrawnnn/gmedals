local gradient = Material("vgui/gradient-d")
local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:Scale(10)
    self.curBarPos = 0

    self.Buttons = {}
    self.ButtonDirect = {}

    self.lerp = 0
    self:SetTall(Nexus:Scale(50))

    self:DockPadding(self.margin, 0, 0, 0)
end

local col_zero = Color(0, 0, 0, 0)
function PANEL:AddItem(str, func, icon)
    func = func or function() end

    local font = Nexus:GetFont(25)
    surface.SetFont(font)
    local tw, th = surface.GetTextSize(str)

    local size = Nexus:Scale(25)
    if icon then
        tw = tw + size
    end

    local button = self:Add("Nexus:Button")
    button:Dock(LEFT)
    button:DockMargin(0, 0, self.margin, 0)
    button.OnSelected = func
    button.str = str
    button.DoClick = function(s)
        func()
        self.Selected = str
    end
    button.Paint = function(s, w, h)
        if s:IsHovered() or (self.Selected == str) then
            Nexus:DrawRoundedGradient(0, 0, w, h-self.margin, col_zero, self.hoverCol)
        end

        if icon then
            Nexus:DrawImgur(icon, self.margin, (h/2) - (size/2), size, size, self.Selected == str and color_white or Nexus:OffsetColor(Nexus.Colors.Text, -100))
        end

        draw.SimpleText(str, Nexus:GetFont(25), icon and self.margin + size + self.margin or w/2, h/2, s:IsHovered() and Nexus.Colors.Text or ((self.Selected == str) and Nexus.Colors.Text or Nexus:OffsetColor(Nexus.Colors.Text, -100)), icon and 0 or 1, 1)
    end

    button:SetWide(tw + self.margin*3)
    table.insert(self.Buttons, button)

    self.ButtonDirect[str] = #self.Buttons

    func()
    self.Selected = str
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
    self.col = self.col or Nexus:OffsetColor(Nexus.Colors.Background, 20, true)
    self.hoverCol = Nexus:OffsetColor(self.col, 20)
    draw.RoundedBox(self.margin, 0, 0, w, h, self.col)

    if #self.ButtonDirect == 0 then return end
    local wide = math.floor(w/#self.Buttons)
    self.lerp = math.min(self.lerp + .8 * FrameTime(), 1)
    self.curBarPos = LerpVector(self.lerp, Vector(self.curBarPos, 0, 0), Vector((self.ButtonDirect[self.Selected]-1)*wide, 0, 0))
    local x, y = math.floor(self.curBarPos.x), h - self.margin

    draw.RoundedBox(self.margin, x, y, wide, self.margin, Nexus.Colors.Primary)
end

function PANEL:PerformLayout(w, h) end
vgui.Register("Nexus:Navbar", PANEL, "EditablePanel")