if SERVER then
    resource.AddFile( "materials/vgui/ttt/icon_autohop.vmt" )
end

AutoHop = AutoHop or {}



local CVars = {}

CVars.autohop_enabled = CreateConVar( "autohop_enabled", "0", FCVAR_SERVER_CAN_EXECUTE+FCVAR_REPLICATED+FCVAR_ARCHIVE )
if CLIENT then
    CVars.autohop = CreateConVar( "autohop", "0", FCVAR_USERINFO+FCVAR_ARCHIVE )
end

AutoHop.CVars = CVars



local gf = {}
local clamp = math.Clamp
local frameTime = FrameTime
local localPlayer = LocalPlayer
local bNot, bAnd, bOr = bit.bnot, bit.band, bit.bor


hook.Add("ShouldAutoHop", "AutoHop", function(ply)
    if CVars.autohop_enabled:GetBool() then
        if SERVER and ply:GetInfo( "autohop" ) then
            return true
        elseif CLIENT and CVars.autohop:GetBool() then
            return true
        end
    end
end)


hook.Add("Move", "AutoHop", function( ply, data )
    if not IsValid( ply ) then return end
    if CLIENT and ply ~= localPlayer() then return end
    if not hook.Call( "ShouldAutoHop", nil, ply ) then return end

    local onground = ply:IsOnGround()
    if onground and not gf[ ply ] then
        gf[ ply ] = 0
    elseif onground and gf[ ply ] then
        gf[ ply ] = gf[ ply ] + 1
        if gf[ ply ] > 12 then
            ply:SetDuckSpeed( 0.4 )
            ply:SetUnDuckSpeed( 0.2 )
        end
    elseif not onground then
        gf[ ply ] = 0
        ply:SetDuckSpeed( 0 )
        ply:SetUnDuckSpeed( 0 )
    end
    
    
    if onground or not ply:Alive() then return end
    
    local aa, mv = 500, 32.8
    local aim = data:GetMoveAngles()
    local forward, right = aim:Forward(), aim:Right()
    local fmove = data:GetForwardSpeed()
    local smove = data:GetSideSpeed()
    
    if data:KeyDown( IN_MOVERIGHT ) then smove = smove + 500 end
    if data:KeyDown( IN_MOVELEFT ) then smove = smove - 500 end
    
    forward.z, right.z = 0,0
    forward:Normalize()
    right:Normalize()

    local wishvel = forward * fmove + right * smove
    wishvel.z = 0

    local wishspeed = wishvel:Length()
    if wishspeed > data:GetMaxSpeed() then
        wishvel = wishvel * (data:GetMaxSpeed() / wishspeed)
        wishspeed = data:GetMaxSpeed()
    end

    local wishspd = wishspeed
    wishspd = clamp( wishspd, 0, mv )

    local wishdir = wishvel:GetNormal()
    local current = data:GetVelocity():Dot( wishdir )

    local addspeed = wishspd - current
    if addspeed <= 0 then return end

    local accelspeed = aa * frameTime() * wishspeed
    if accelspeed > addspeed then
        accelspeed = addspeed
    end
    
    local vel = data:GetVelocity()
    vel = vel + (wishdir * accelspeed)
    
    data:SetVelocity( vel )
    return false
end)

hook.Add( "SetupMove", "AutoHop", function( ply, data )
    if CLIENT and ply ~= localPlayer() then return end
    if not hook.Call( "ShouldAutoHop", nil, ply ) then return end

    local ButtonData = data:GetButtons()
    if bAnd( ButtonData, IN_JUMP ) > 0 then
        if ply:WaterLevel() < 2 and ply:GetMoveType() ~= MOVETYPE_LADDER and not ply:IsOnGround() then
            data:SetButtons( bAnd( ButtonData, bNot( IN_JUMP ) ) )
        end
    end
end )
