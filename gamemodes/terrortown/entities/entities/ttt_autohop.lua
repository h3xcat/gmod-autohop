if SERVER then AddCSLuaFile() end

	
EQUIP_AUTOHOP = GenerateNewEquipmentID()

local CVars = AutoHop.CVars

CVars.autohop_ttt_detective = CreateConVar( "autohop_ttt_detective", "0", FCVAR_SERVER_CAN_EXECUTE+FCVAR_REPLICATED+FCVAR_ARCHIVE )
CVars.autohop_ttt_traitor = CreateConVar( "autohop_ttt_traitor", "0", FCVAR_SERVER_CAN_EXECUTE+FCVAR_REPLICATED+FCVAR_ARCHIVE )    


if CVars.autohop_ttt_detective:GetBool() then
    table.insert(EquipmentItems[ROLE_DETECTIVE], 
        {  id       = EQUIP_AUTOHOP,
            loadout  = false,
            type     = "Passive effect item",
            material = "vgui/ttt/icon_autohop",
            name     = "AutoHop",
            desc     = "Allows you to hop like a bunny."
        }
    )
end

if CVars.autohop_ttt_traitor:GetBool() then
    table.insert(EquipmentItems[ROLE_TRAITOR], 
        {  id       = EQUIP_AUTOHOP,
            loadout  = false,
            type     = "Passive effect item",
            material = "vgui/ttt/icon_autohop",
            name     = "AutoHop",
            desc     = "Allows you to hop like a bunny."
        }
    )
end


hook.Add("ShouldAutoHop", "AutoHop_TTT", function(ply)
    if ply:HasEquipmentItem(EQUIP_AUTOHOP) then
        return true
    end
end)