if SERVER then
    // to make the sh_builder happy
    function Nexus:Scale(number) end
end

Nexus.Addons = Nexus.Addons or {}

local BUILDER = {}
BUILDER.Elements = {}
function BUILDER:Start()
    local data = table.Copy(BUILDER)
    data.name = "Addon ID"

    return data
end

function BUILDER:SetName(str)
    self.name = str

    return self
end

function BUILDER:AddLabel(tbl)
    tbl = tbl or {}
    tbl.text = tbl.text or ""

    table.Add(self.Elements, {{id = "label", text = tbl.text, margin = tbl.margin, size = tbl.size}})

    return self
end

function BUILDER:AddButtons(tbl)
    tbl = tbl or {}

    if tbl.label then
        self:AddLabel({text = tbl.label})
    end

    table.Add(self.Elements, {{id = "button-row", data = tbl}})

    self:AddLabel({text = ""})
    return self
end

function BUILDER:AddTextEntry(tbl)
    tbl = tbl or {}

    if tbl.label then
        self:AddLabel({text = tbl.label})
    end

    table.Add(self.Elements, {{id = "text-entry", data = tbl}})

    self:AddLabel({text = ""})
    return self
end

function BUILDER:AddMultiTextEntry(tbl)
    tbl = tbl or {}
    tbl.defaultValue = {}
    for _, v in ipairs(tbl.entries) do
        tbl.defaultValue[v.id] = v.default
    end

    if tbl.label then
        self:AddLabel({text = tbl.label})
    end

    table.Add(self.Elements, {{id = "multi-text-entry", data = tbl}})

    self:AddLabel({text = ""})
    return self
end

function BUILDER:AddKeyTable(tbl)
    tbl = tbl or {}

    if tbl.label then
        self:AddLabel({text = tbl.label})
    end

    table.Add(self.Elements, {{id = "key-table", data = tbl}})

    self:AddLabel({text = ""})
    return self
end

function BUILDER:AddTable(tbl)
    tbl = tbl or {}

    if tbl.label then
        self:AddLabel({text = tbl.label})
    end

    if tbl.isPercentage then
        table.Add(tbl.values, {{id = "Chance", type = "TextEntry", placeholder = "weight", isNumeric = true}})
    end

    table.Add(self.Elements, {{id = "table", data = tbl}})

    self:AddLabel({text = ""})
    return self
end

function BUILDER:End()
    for k, v in ipairs(Nexus.Addons) do
        if v.name == self.name then
            table.remove(Nexus.Addons, k)
            break
        end
    end

    table.Add(Nexus.Addons, {self})
end

Nexus.Builder = BUILDER