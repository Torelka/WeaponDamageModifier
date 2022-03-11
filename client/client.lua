

--- DebugTool
local aiming=false
RegisterCommand("aim2",function ()
    aiming=aiming==false and true or false
end)
Healcooldown = false

RegisterCommand('heal', function(source, args, rawCommand)
        notify("~g~Healed")
        SetEntityHealth(GetPlayerPed(-1), 200)
end)
function notify(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(true,false)
end

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(500)
        if(aiming) then
            local player=GetPlayerPed(-1)
            while aiming do
                Citizen.Wait(0)
                local modifier=GetPlayerWeaponDamageModifier(PlayerId())
                local result,entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
                local health = GetEntityHealth(entity)
                drawTxt("Modificateur de dégat", 4, {255, 255, 255}, 0.4, 0.530 , 0.160,"STRING")               
                drawTxt(tostring(modifier), 4, {255, 255, 255}, 0.4, 0.640 , 0.160,"STRING")
                drawTxt("EntityHealth", 4, {255, 255, 255}, 0.4, 0.530 , 0.180,"STRING")               
                drawTxt(tostring(health), 4, {255, 255, 255}, 0.4, 0.640 , 0.180,"STRING")
            end
        end
    end
end)
--- /DebugTool



Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(0)
        local result,entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
        local isAPlayer=IsPedAPlayer(entity)
        local hashWeapon=GetSelectedPedWeapon(GetPlayerPed(-1))
        if(isAPlayer and hashWeapon==-1466123874) then
            SetPlayerWeaponDamageModifier(PlayerId(),0.3)
        else
            SetPlayerWeaponDamageModifier(PlayerId(),1.0)
        end        
    end
end)

function drawTxt(content, font, colour, scale, x, y,type)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1],colour[2],colour[3], 255)
    SetTextEntry(type)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    EndTextCommandDisplayText(x, y)
end


--------------------------------
--- RP Revive, Made by FAXES ---
--------------------------------

--- Config ---

local reviveWait = 90 -- Change the amount of time to wait before allowing revive (in seconds).
local featureColor = "~y~" -- Game color used as the button key colors.

--- Code ---
local timerCount = reviveWait
local isDead = false
cHavePerms = true





function respawnPed(ped, coords)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, true, false) 
	SetPlayerInvincible(ped, false) 
	TriggerEvent('playerSpawned', coords.x, coords.y, coords.z, coords.heading)
	ClearPedBloodDamage(ped)
end

function revivePed(ped)
	local playerPos = GetEntityCoords(ped, true)
	isDead = false
	timerCount = reviveWait
	NetworkResurrectLocalPlayer(playerPos, true, true, false)
	SetPlayerInvincible(ped, false)
	ClearPedBloodDamage(ped)
end

function ShowInfoRevive(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentSubstringPlayerName(text)
	DrawNotification(true, true)
end

Citizen.CreateThread(function()
	local respawnCount = 0
	local spawnPoints = {}
	local playerIndex = NetworkGetPlayerIndex(-1) or 0
	math.randomseed(playerIndex)

	function createSpawnPoint(x1, x2, y1, y2, z, heading)
		local xValue = math.random(x1,x2) + 0.0001
		local yValue = math.random(y1,y2) + 0.0001

		local newObject = {
			x = xValue,
			y = yValue,
			z = z + 0.0001,
			heading = heading + 0.0001
		}
		table.insert(spawnPoints,newObject)
	end

	createSpawnPoint(-448, -448, -340, -329, 35.5, 0) -- Mount Zonah
	createSpawnPoint(372, 375, -596, -594, 30.0, 0)   -- Pillbox Hill
	createSpawnPoint(335, 340, -1400, -1390, 34.0, 0) -- Central Los Santos
	createSpawnPoint(1850, 1854, 3700, 3704, 35.0, 0) -- Sandy Shores
	createSpawnPoint(-247, -245, 6328, 6332, 33.5, 0) -- Paleto


    while true do
    Citizen.Wait(0)
		ped = GetPlayerPed(-1)
        if IsEntityDead(ped) then
			isDead = true
            SetPlayerInvincible(ped, true)
            SetEntityHealth(ped, 1)
			ShowInfoRevive('You are dead. Use ~y~E ~w~to revive or ~y~R ~w~to respawn.')
            if IsControlJustReleased(0, 38) and GetLastInputMethod(0) then
                if timerCount <= 0 or cHavePerms then
                    revivePed(ped)
				else
					TriggerEvent('chat:addMessage', {args = {'^*Wait ' .. timerCount .. ' more seconds before reviving.'}})
                end	
            elseif IsControlJustReleased(0, 45) and GetLastInputMethod( 0 ) then
                local coords = spawnPoints[math.random(1,#spawnPoints)]
				respawnPed(ped, coords)
				isDead = false
				timerCount = reviveWait
				respawnCount = respawnCount + 1
				math.randomseed(playerIndex * respawnCount)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if isDead then
			timerCount = timerCount - 1
        end
        Citizen.Wait(1000)          
    end
end)