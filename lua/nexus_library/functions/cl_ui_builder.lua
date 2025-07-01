local panels = {}
local int = 1

local BASE = {}
BASE.Panels = {}
BASE.Selected = {}
BASE.SelectedSpecial = {}
function BASE:Start(tbl)
    tbl = tbl or {}
    tbl.debug = tbl.debug or false

    BASE.debug = tbl.debug
    local mod = table.Copy(BASE)
    mod.margin = Nexus:Scale(10)
    return mod
end

function BASE:CreateFrame(tbl)
    tbl = tbl or {}

    tbl.size = tbl.size or {}
    tbl.size.w = tbl.size.w or Nexus:Scale(200)
    tbl.size.h = tbl.size.h or Nexus:Scale(300)

    tbl.title = tbl.title or ""

    tbl.id = tbl.id or int
    int = int + 1

    if IsValid(panels[tbl.id]) then
        panels[tbl.id]:Remove()
        panels[tbl.id] = nil
    end

    local background
    if tbl.darken then
        background = vgui.Create("DPanel")
        background:SetSize(ScrW(), ScrH())
        background:MakePopup()
        background.Paint = function(s, w, h)
            surface.SetDrawColor(0, 0, 0, 230)
            surface.DrawRect(0, 0, w, h)
        end
    end

    local frame = IsValid(background) and background:Add("Nexus:Frame") or vgui.Create("Nexus:Frame")
    frame:SetSize(tbl.size.w, tbl.size.h)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle(tbl.title, tbl.icon)
    frame.OnRemove = function()
        if IsValid(background) then
            background:Remove()
        end
    end

    local old = frame.Think
    frame.Think = function(s)
        old(s)
        if IsValid(background) then
            s:MoveToFront()
        end

        if tbl.reference and not IsValid(tbl.reference) then
            frame:Remove()
        end
    end

    panels[tbl.id] = frame

    self.Selected = frame
    self:Update()
    table.insert(self.Panels, frame)

    return self
end

function BASE:AddNavbar(tbl)
    tbl = tbl or {}

    tbl.size = tbl.size or {}
    tbl.size.w = tbl.size.w or Nexus:Scale(200)
    tbl.size.h = tbl.size.h or Nexus:Scale(300)
    tbl.margin = tbl.margin or Nexus:Scale(10)

    local navbar = (self.Selected.isCategory and self.Selected.Canvas or self.Selected):Add("Nexus:Navbar")
    navbar:Dock(TOP)
    navbar:DockMargin(self.Selected.isBlock and 0 or tbl.margin, self.Selected.isBlock and 0 or tbl.margin, tbl.margin, 0)
    navbar.isNavbar = true

    self.SelectedSpecial = navbar
    table.insert(self.Panels, navbar)

    return self
end

function BASE:AddChoice(text, func, icon)
    func = func or function() end

    if self.SelectedSpecial.isCombo then
        self.SelectedSpecial:AddChoice(text, func)
    elseif self.SelectedSpecial.isNavbar then
        self.SelectedSpecial:AddItem(text, func, icon)
    end
    return self
end

function BASE:AddText(tbl)
    tbl = tbl or {}
    tbl.text = tbl.text or ""
    tbl.margin = tbl.margin or self.margin
    tbl.align = tbl.align or 4
    local text = (self.Selected.isCategory and self.Selected.Canvas or self.Selected):Add("DLabel")
    text:Dock(self.Selected.isBlock and LEFT or TOP)
    text:DockMargin(self.Selected.isBlock and 0 or tbl.margin, self.Selected.isBlock and 0 or tbl.margin, tbl.margin, 0)
    text:SetText(tbl.text)
    text:SetFont(Nexus:GetFont(20))
    text:SizeToContents()
    text:SetContentAlignment(tbl.align)

    table.insert(self.Panels, text)

    return self
end

function BASE:AddSpacer()
    local spacer = (self.Selected.isCategory and self.Selected.Canvas or self.Selected):Add("DPanel")
    spacer:Dock(TOP)
    spacer:DockMargin(self.margin, self.margin, self.margin, 0)
    spacer:SetTall(Nexus:Scale(3))
    spacer:SetBackgroundColor(Nexus.Colors.Outline)

    table.insert(self.Panels, spacer)

    return self
end

function BASE:AddBlock(tbl)
    tbl = tbl or {}
    tbl.padding = tbl.padding or self.margin

    tbl.size = tbl.size or {}
    tbl.size.h = tbl.size.h or Nexus:Scale(50)

    local panel = (self.Selected.isCategory and self.Selected.Canvas or self.Selected):Add("DPanel")
    panel:Dock(TOP)
    panel:DockPadding(tbl.padding, tbl.padding, tbl.padding, 0)
    panel:DockMargin(self.margin, self.margin, self.margin, 0)
    panel:SetTall(tbl.size.h)
    panel.Paint = function(s, w, h)
        draw.RoundedBox(Nexus:Scale(10), 0, 0, w, h, Nexus:OffsetColor(Nexus.Colors.Background, 20, true))
    end

    local scrollBar = panel:Add("Nexus:HorizontalScrollPanel")
    scrollBar:Dock(FILL)
    scrollBar.isBlock = true
    scrollBar.overrideParent = panel:GetParent()

    if tbl.dontDraw then
        panel.Paint = nil
    end

    self.Selected = scrollBar
    self:Update()
    table.insert(self.Panels, scrollBar)

    return self
end

function BASE:AddButton(tbl)
    tbl = tbl or {}
    tbl.text = tbl.text or ""
    tbl.DoClick = tbl.DoClick or function(s) end
    tbl.margin = tbl.margin or self.margin
    tbl.color = tbl.color or Nexus.Colors.Primary
    tbl.font = tbl.font or Nexus:GetFont(20)

    tbl.size = tbl.size or {}
    tbl.size.h = tbl.size.h or Nexus:Scale(50)

    local button = (self.Selected.isCategory and self.Selected.Canvas or self.Selected):Add("Nexus:Button")
    button:Dock(self.Selected.isBlock and LEFT or TOP)
    button:DockMargin(self.Selected.isBlock and 0 or tbl.margin, self.Selected.isBlock and 0 or tbl.margin, tbl.margin, 0)
    button:SetText(tbl.text)
    button.DoClick = tbl.DoClick
    button:SetColor(tbl.color)
    button:SetTall(tbl.size.h)
    button:SetFont(tbl.font)

    button:AutoWide()

    table.insert(self.Panels, button)

    return self
end

function BASE:AddCheckbox(tbl)
    tbl = tbl or {}
    tbl.text = tbl.text or ""
    tbl.margin = tbl.margin or self.margin
    tbl.stateChanged = tbl.stateChanged or function(s, state) end
    tbl.state = tbl.state or false

    tbl.size = tbl.size or {}
    tbl.size.h = tbl.size.h or Nexus:Scale(50)

    local checkBox = (self.Selected.isCategory and self.Selected.Canvas or self.Selected):Add("Nexus:CheckBox")
    checkBox:Dock(self.Selected.isBlock and LEFT or TOP)
    checkBox:DockMargin(self.Selected.isBlock and 0 or tbl.margin, self.Selected.isBlock and 0 or tbl.margin, tbl.margin, 0)
    checkBox:SetText(tbl.text)
    checkBox:SetTall(tbl.size.h)
    checkBox:AutoWide()
    checkBox.OnStateChanged = function(s, value)
        tbl.stateChanged(value)
    end
    checkBox:SetState(tbl.state)

    table.insert(self.Panels, checkBox)

    return self
end

function BASE:AddComboBox(tbl)
    tbl = tbl or {}
    tbl.margin = tbl.margin or self.margin
    tbl.text = tbl.text or "N/A"

    tbl.size = tbl.size or {}
    tbl.size.h = tbl.size.h or Nexus:Scale(50)

    local comboBox = (self.Selected.isCategory and self.Selected.Canvas or self.Selected):Add("Nexus:ComboBox")
    comboBox:Dock(self.Selected.isBlock and LEFT or TOP)
    comboBox:DockMargin(self.Selected.isBlock and 0 or tbl.margin, self.Selected.isBlock and 0 or tbl.margin, tbl.margin, 0)
    comboBox:SetTall(tbl.size.h)
    comboBox:SetText(tbl.text)
    comboBox:AutoWide()
    comboBox.isCombo = true

    self.SelectedSpecial = comboBox

    table.insert(self.Panels, comboBox)

    return self
end

function BASE:AddNumSlider(tbl)
    tbl = tbl or {}
    tbl.margin = tbl.margin or self.margin
    tbl.value = tbl.value or 0

    tbl.size = tbl.size or {}
    tbl.size.h = tbl.size.h or Nexus:Scale(50)
    tbl.max = tbl.max or 100

    tbl.onChange = tbl.onChange or function() end

    local numSlider = (self.Selected.isCategory and self.Selected.Canvas or self.Selected):Add("Nexus:NumSlider")
    numSlider:Dock(self.Selected.isBlock and LEFT or TOP)
    numSlider:DockMargin(self.Selected.isBlock and 0 or tbl.margin, self.Selected.isBlock and 0 or tbl.margin, tbl.margin, 0)
    numSlider:SetTall(tbl.size.h)
    numSlider:SetWide(Nexus:Scale(350))
    numSlider:SetValue(tbl.value)
    numSlider:SetMax(tbl.max)
    numSlider.OnChange = function(s, val)
        tbl.onChange(val)
    end

    table.insert(self.Panels, numSlider)

    return self
end

function BASE:AddCategory(tbl)
    tbl = tbl or {}
    tbl.margin = tbl.margin or self.margin
    tbl.title = tbl.title or ""

    tbl.size = tbl.size or {}
    tbl.size.h = tbl.size.h or Nexus:Scale(50)

    local category = (self.Selected.isCategory and self.Selected.Canvas or self.Selected):Add("Nexus:Category")
    category:Dock(self.Selected.isBlock and LEFT or TOP)
    category:DockMargin(self.Selected.isBlock and 0 or tbl.margin, self.Selected.isBlock and 0 or tbl.margin, tbl.margin, 0)
    category:SetTall(tbl.size.h)
    category:SetText(tbl.title)

    category.isCategory = true

    self.Selected = category
    self:Update()

    table.insert(self.Panels, category)

    return self
end

function BASE:AddScrollPanel()
    local scrollPanel = (self.Selected.isCategory and self.Selected.Canvas or self.Selected):Add("Nexus:ScrollPanel")
    scrollPanel:Dock(FILL)
    scrollPanel:DockMargin(0, self.margin, self.margin, self.margin)

    self.Selected = scrollPanel
    self:Update()
    table.insert(self.Panels, scrollPanel)

    return self
end

function BASE:AddTextEntry(tbl)
    tbl = tbl or {}
    tbl.text = tbl.text or ""
    tbl.placeholder = tbl.placeholder or ""
    tbl.margin = tbl.margin or self.margin
    tbl.onChange = tbl.onChange or function() end
    tbl.isNumeric = tbl.isNumeric or false

    tbl.size = tbl.size or {}
    tbl.size.h = tbl.size.h or Nexus:Scale(50)

    local textEntry = (self.Selected.isCategory and self.Selected.Canvas or self.Selected):Add("Nexus:TextEntry")
    textEntry:Dock(self.Selected.isBlock and LEFT or TOP)
    textEntry:DockMargin(self.Selected.isBlock and 0 or tbl.margin, self.Selected.isBlock and 0 or tbl.margin, tbl.margin, 0)
    textEntry:SetText(tbl.text)
    textEntry:SetPlaceholder(tbl.placeholder)
    textEntry:SetTall(tbl.size.h)
    textEntry:SetNumeric(tbl.isNumeric)
    textEntry.OnChange = function(s, val)
        tbl.onChange(val)
    end

    table.insert(self.Panels, textEntry)

    return self
end

function BASE:GetLastPanel()
    return self.Panels[#self.Panels]
end

function BASE:BackupParent()
    self.Selected = self.Selected.overrideParent or self.Selected:GetParent()

    while self.Selected.overrideParent do
        self.Selected = self.Selected.overrideParent
    end

    self:Update()
    return self
end

function BASE:Update()
    if self.NewParentFunc then
        self.NewParentFunc(self.Selected)
    end

    local old = self.Selected.Paint or function() end
    if not self.Selected.NFormatted and self.debug then
        self.Selected.Paint = function(s, w, h)
            old(s, w, h)
            if s == self.Selected then
                surface.SetDrawColor(255, 179, 46, 20)
                surface.DrawRect(0, 0, w, h)
            end
        end
    end
    self.Selected.NFormatted = true
end

function BASE:AddIconButton(tbl)
    tbl = tbl or {}
    tbl.DoClick = tbl.DoClick or function() end
    tbl.icon = tbl.icon or ""

    self.Selected:AddButton(tbl.icon, tbl.DoClick)

    return self
end

function BASE:OnNewSelection(func)
    self.NewParentFunc = func

    return self
end
Nexus.UIBuilder = BASE