local PANEL = {}
function PANEL:Init()
	self.margin = Nexus:Scale(10)

	self.VBar:SetHideButtons(true)
	self.VBar:SetWide(Nexus:Scale(12))

	local col = table.Copy(Nexus.Colors.Secondary)
	col.a = 100
	self.VBar.Paint = function(s, w, h)
		draw.RoundedBox(self.margin, 0, 0, w, h, col)
	end

	self.VBar.btnGrip.Paint = function(s, w, h)
		Nexus:DrawRoundedGradient(0, 0, w, h, Nexus.Colors.Primary)
	end
end
vgui.Register("Nexus:ScrollPanel", PANEL, "DScrollPanel")