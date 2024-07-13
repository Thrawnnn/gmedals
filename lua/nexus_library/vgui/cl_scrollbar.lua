local PANEL = {}
function PANEL:Init()
	self.margin = Nexus:Scale(6)

	self.VBar:SetHideButtons(true)
	self.VBar:SetWide(self.margin*2)

	local col = table.Copy(Nexus.Colors.Secondary)
	col.a = 100
	self.VBar.Paint = function(s, w, h)
		draw.RoundedBox(self.margin, 0, 0, w, h, col)
	end

	self.VBar.btnGrip.Paint = function(s, w, h)
		draw.RoundedBox(self.margin, 0, 0, w, h, Nexus.Colors.Secondary)
	end
end
vgui.Register("Nexus:ScrollPanel", PANEL, "DScrollPanel")