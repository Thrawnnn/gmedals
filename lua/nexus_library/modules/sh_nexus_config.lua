Nexus.Builder:Start()
    :SetName("Nexus Core")

    :AddKeyTable({
        id = "nexus-config-admins",
        dontNetwork = false,
        defaultValue = {
            ["superadmin"] = true,
        },

        label = "Ranks that can edit nexus_config values",

        placeholder = "Usergroup",
        isNumeric = false,

        onChange = function(value) end,
    })
:End()