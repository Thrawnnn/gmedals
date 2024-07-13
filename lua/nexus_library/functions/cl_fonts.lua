Nexus = Nexus or {}

local fontCache = {}
function Nexus:GetFont(size, dontScale)
    local name = "Nexus:"..tostring(size)..":"..(dontScale and "Non" or "Scaled")
    if fontCache[name] then return name end
    surface.CreateFont(name, {
        font = "Lato",
        size = dontScale and size or Nexus:Scale(size),
        weight = 500,
        extended = true,
        antialias = true,
    })

    fontCache[name] = {size, dontScale}
    return name
end

hook.Add("OnScreenSizeChanged", "Nexus:ScaleFonts", function()
    for name, v in pairs(fontCache) do
        if v[2] then continue end
        surface.CreateFont(name, {
            font = "Lato",
            size = Nexus:Scale(v[1]),
            weight = 500,
            extended = true,
            antialias = true,
        })    
    end
end)