local PANEL = {}
AccessorFunc(PANEL, "Placeholder", "Placeholder")
AccessorFunc(PANEL, "PlaceholderColor", "PlaceholderColor")
AccessorFunc(PANEL, "Disabled", "Disabled", FORCE_BOOL)
function PANEL:Init()
	self.margin = Nexus:Scale(10)

    self:SetPlaceholder("")
	self:SetPlaceholderColor(Color(120, 120, 120))

	self.TextEntry = self:Add("DTextEntry")
	self.TextEntry:Dock(FILL)
	self.TextEntry:DockMargin(self.margin+2, self.margin+2, self.margin+2, self.margin+2)
	self.TextEntry:SetFont(Nexus:GetFont(20))
	self.TextEntry.Paint = function(s, w, h)
		local col = Nexus.Colors.Text
		s:DrawTextEntryText(col, col, col)

		if (#s:GetText() == 0) then
			draw.SimpleText(self:GetPlaceholder() or "", s:GetFont(), 2, s:IsMultiline() and self.margin or h / 2, self:GetPlaceholderColor(), self.centerText and 1 or TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
	self.TextEntry.OnValueChange = function(s)
		self:OnValueChange(text)
	end
	self.TextEntry.OnChange = function(s)
		self:OnChange()
	end
	self.TextEntry.OnEnter = function(s)
		self:OnEnter()
	end
end

function PANEL:OnEnter() end
function PANEL:OnChange() end
function PANEL:SetNumeric(bool) self.TextEntry:SetNumeric(true) end
function PANEL:GetNumeric() return self.TextEntry:GetNumeric() end
function PANEL:SetUpdateOnType(bool) self.TextEntry:SetUpdateOnType(true) end
function PANEL:GetUpdateOnType() return self.TextEntry:GetUpdateOnType() end
function PANEL:OnValueChange() end
function PANEL:GetValue() return self.TextEntry:GetValue() end
function PANEL:SetFont(str)
	self.TextEntry:SetFont(str)
end

function PANEL:GetFont()
	return self.TextEntry:GetFont()
end

function PANEL:GetText()
	return self.TextEntry:GetText()
end

function PANEL:SetText(str)
	str = str or ""
	self.TextEntry:SetText(str)
end

function PANEL:SetMultiLine(state)
	self.TextEntry:SetMultiline(state)
end

function PANEL:OnMousePressed()
	self.TextEntry:RequestFocus()
end

function PANEL:CenterPlaceholder()
	self.centerText = true
end

function PANEL:Paint(w, h)
    Nexus:DrawRoundedGradient(0, 0, w, h, Nexus.Colors.Primary)
	draw.RoundedBox(self.margin, 2, 2, w-4, h-4, Nexus.Colors.Background)
end
vgui.Register("Nexus:TextEntry", PANEL, "EditablePanel")