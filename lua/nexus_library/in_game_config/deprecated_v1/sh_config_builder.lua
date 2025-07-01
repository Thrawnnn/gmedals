// please use the other builder this is the old version but i have kept it 
// in case addons still rely on it
Nexus.Config.Addons = Nexus.Config.Addons or {}
function Nexus.Config:AddAddon(name)
    Nexus.Config.Addons[name] = {
        Options = {},
    }
end

local count = 0
function Nexus.Config:AddValue(addon, id, title, values, default, type, onComplete, order, lines, resetMenu, dontNetwork)
    count = count + 1

    order = order or count
    Nexus.Config.Addons[addon].Options[id] = {
        title = title,
        values = values,
        default = default,
        type = type,
        onComplete = onComplete,
        order = order,
        lines = lines or false,
        resetMenu = resetMenu or false,
        dontNetwork = dontNetwork or false,
    }
end

function Nexus.Config:GetValue(addon, id)
    if SERVER then
        return Nexus:GetValue(addon, id)
    end

    return Nexus.Config.Addons[addon].Options[id].default
end