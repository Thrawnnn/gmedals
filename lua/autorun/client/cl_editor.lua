-- Then font named "Font" compacted on one line.
surface.CreateFont("Font", {
    font = "Arial",
    extended = true,
    size = 20
})

local faded_black = Color(0, 0, 0, 200) -- The color black but with 200 Alpha

concommand.Add( "gmedal_edit", function()
	local DermaPanel = vgui.Create("DFrame") 
	DermaPanel:SetSize(ScrW() / 4, ScrH() / 3)
	DermaPanel:Center() 
	DermaPanel:SetTitle("") 
	DermaPanel:SetDraggable(false)
	DermaPanel:MakePopup() 

	DermaPanel.Paint = function(self, w, h)
	    draw.RoundedBox(2, 0, 0, w, h, faded_black)
	    draw.SimpleText("GMedals", "Font", 250, 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

    
    local DScrollPanel = vgui.Create( "DScrollPanel", DermaPanel )
    DScrollPanel:Dock( FILL )
    
    for k,v in pairs(gMedals.Config) do
        local DButton = DScrollPanel:Add( "DImageButton" )
        DButton:SetSize(25,150)
        DButton:SetImage( gMedals.Config[k].editorMat or gMedals.FallBackImage ) -- make the image button the material for the award OR fallback to a default image.
        --DButton:SetText( gMedals.Config[k].name )
        DButton:Dock( TOP )
        DButton:DockMargin( 0, 0, 250, 5 )
        DButton:SetToolTip(gMedals.Config[k].name.." - "..gMedals.Config[k].desc) -- sets the tooltip to have the name followed by the description, e.g 'Cadet - This player is a cadet!''
        DButton.Paint = function(s,w,h)
            draw.RoundedBox(2, 0, 0, w, h, Color(50,50,50,255))
        end

        local selection = vgui.Create( "DComboBox", DermaPanel )
        selection:SetPos( 225, 75 )
        selection:SetSize( 200, 20 )
        selection:SetValue( "Give or take away?" )

        selection.OnSelect = function( _, _, value )
            type = value -- sets the target for later use
        end

        selection:AddChoice( "Give Medal" )
        selection:AddChoice( "Take Medal")
 
        
        local comboBox = vgui.Create( "DComboBox", DermaPanel )
        comboBox:SetPos( 225, 29 )
        comboBox:SetSize( 200, 20 )
        comboBox:SetValue( "Choose your target:" )

        comboBox.OnSelect = function( _, _, value )
            target = value -- sets the target for later use
        end

        for _, t in ipairs( player.GetAll() ) do
            comboBox:AddChoice( t:Name() )
        end

         DButton.DoClick = function()
            surface.PlaySound(gMedals.ButtonSound)
            
            if not target then
                print("[gMedal Error!] No target selected!")
            end

            for _,n in player.Iterator() do
                if n:Name() == target then
                    if type == "Give Medal" then
                        net.Start("UpdateMedals")
                            net.WriteInt(gMedals.Config[k].id, 8)
                            net.WritePlayer(n)
                        net.SendToServer()
                        n:GiveMedal(gMedals.Config[k].id)
                        print("[gMedal Logger] Giving "..n:Name().." (ENT ID: "..tostring(n).." ) "..gMedals.Config[k].name) 
                    elseif type == "Take Medal" then 
                        n:RemoveMedal(gMedals.Config[k].id)
                        net.Start("UpdateMedalsRemove")
                            net.WriteInt(gMedals.Config[k].id, 8)
                            net.WritePlayer(n)
                        net.SendToServer()

                        print("[gMedal Logger] Removing "..gMedals.Config[k].name.." from "..n:Name().." (ENT ID: "..tostring(n).." ) ") 
                    end
                    break -- stop the loop when the targets found, just best practice for performance ratings :)
                end
            end
            -- OMG NO SHOT I DID ALL THIS IN ONE TRY WITHOUT ERRORS I AM SO SMART BRO
        end
    end

end )