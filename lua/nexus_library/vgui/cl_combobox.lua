local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:Scale(10)
	self:SetFont(Nexus:GetFont(25))
	self:SetTextColor(Color(120, 120, 120))

	local old = self.DoClick
	self.DoClick = function(s)
		old(s)

		if not IsValid(s.Menu) then return end
		for _, b in ipairs(s.Menu:GetChildren()[1]:GetChildren()) do
			b:SetFont(Nexus:GetFont(20))
			b:SetContentAlignment(5)
			b:SetColor(Nexus.Colors.Text)
			b.Paint = function(s, w, h)		
				draw.RoundedBox(0, 0, 0, w, h, s:IsHovered() and Nexus:OffsetColor(Nexus.Colors.Secondary, 20) or Nexus.Colors.Secondary)
			end
		end
	end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(self.margin, 0, 0, w, h, Nexus.Colors.Secondary)
end
vgui.Register("Nexus:ComboBox", PANEL, "DComboBox")