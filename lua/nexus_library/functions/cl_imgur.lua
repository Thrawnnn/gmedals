local draw = draw

local replace = { ":", "/", }
function Nexus:ParseKey( k )
    local a = string.lower( k )
    for i=1, #replace do
        a = string.Replace( a, replace[i], "_" )
    end
    return a
end

function Nexus:SaveData( sid, path, name, data, bool, format )
    path = ( path or "nexus_datasave" )
    format = format or "dat"
    file.CreateDir( path )
    if sid then
        local a = self:ParseKey( sid )
        file.CreateDir( path .. "/" .. a )
        path = ( path .. "/" .. a .. "/" )
    else
        path = ( path .. "/" )
    end
    path = ( path .. name .. "." .. format )
    file.Write( path, ( bool and util.TableToJSON( data, true ) or data ) )
end

function Nexus:LoadData( sid, path, name, bool, format )
    path = ( path or "nexus_datasave" )
    format = format or "dat"
    if sid then
        local a = self:ParseKey( sid )
        path = ( path .. "/" .. a .. "/" )
    else
        path = ( path .. "/" )
    end
    path = ( path .. name .. "." .. format )
    if file.Exists( path, "DATA" ) then
        local r = file.Read( path, "DATA" )
        return ( bool and util.JSONToTable( r ) or r )
    end
    return false
end

function Nexus:ParseURL( s )
	s = string.Replace( s, "https://", "" )
	s = string.Replace( s, "http://", "" )
	s = string.Replace( s, "i.imgur.com/", "" )
	s = string.Replace( s, "imgur.com/", "" )
	s = string.Replace( s, ".png", "" )
	s = string.Replace( s, ".jpeg", "" )
	s = string.Replace( s, ".jpg", "" )
	s = string.Replace( s, "/", "" )
	return s
end

Nexus.Materials = {}
function Nexus:GetImgur( id )
    id = self:ParseURL( id )
    if self.Materials[ id ] then return self.Materials[ id ] end
    self.Materials[ id ] = Material( "color" )
    if self:LoadData( nil, "nexus", id, false, "png" ) then
        self.Materials[ id ] = Material( "../data/nexus/" .. id .. ".png", "noclamp smooth" )
        return self.Materials[ id ]
    end
    http.Fetch( "https://i.imgur.com/" .. id .. ".png", function( b )
        self:SaveData( nil, "nexus", id, b, false, "png" )
        self.Materials[ id ] = Material( "../data/nexus/" .. id .. ".png", "noclamp smooth" )
    end, function( error ) return self:DrawImgur( id ) end )
    return self.Materials[ id ]
end

function Nexus:DrawImgur( id, x, y, w, h, color, r )
    x = x or 0; y = y or 0; w = w or 0; h = h or 0; color = color or color_white;

    surface.SetDrawColor( color or color_white )
    surface.SetMaterial( self:GetImgur( id ) )
    if r then
        surface.DrawTexturedRectRotated( x, y, w, h, r )
    else
        surface.DrawTexturedRect( x, y, w, h )
    end
end