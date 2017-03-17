local WEAPON_PROB = 40

local BLIP_COLOR_R = {255, 0, 0, 255}
local BLIP_COLOR_G = {255, 255, 0, 100}
local BLIP_COLOR_B = {255, 0, 255, 60}

local WEAPONS_LVL_1 = {8, 9, 22, 23, 24}
local WEAPONS_LVL_2 = {33, 34, 17, 25, 26}
local WEAPONS_LVL_3 = {30, 31, 16, 18, 27}
local WEAPONS_LVL_4 = {35, 36, 37, 38, 28, 29, 32}
local WEAPONS = {WEAPONS_LVL_1, WEAPONS_LVL_2, WEAPONS_LVL_3, WEAPONS_LVL_4}

local weaponSpawnVehicles = {}
local weaponMarkers = {}

function spawnWeapons( startedMap )
	weaponSpawnVehicles = {}
	weaponMarkers = {}

	--local mapRoot = getResourceRootElement( startedMap )
    local vehicles = getElementsByType ( "vehicle")-- , mapRoot )
	for k,v in ipairs(vehicles) do
		if(math.random(1,100) <= WEAPON_PROB) then
			local levelRand = math.random(1,100)
			local level = 1
			if(levelRand > 90) then
				level = 4
			elseif (levelRand > 60) then
				level = 3
			elseif( levelRand > 30) then
				level = 2
			end
			local marker = createMarker ( 0, 0, 1, "arrow", 1.0, BLIP_COLOR_R[level], BLIP_COLOR_G[level], BLIP_COLOR_B[level])
			attachElements ( marker, v, 0, 0, 2 )
			weaponSpawnVehicles[v] = level
			weaponMarkers[v] = marker
		end
	end
end
addEventHandler("onGamemodeMapStart", getRootElement(), spawnWeapons)

function enterVehicleToSpawnWeapon ( theVehicle, seat, jacked ) --when a player enters a vehicle
    local level = weaponSpawnVehicles[theVehicle]
	if(level ~= nil) then
		outputDebugString("Weapon level "..level)
		local weaponsList = WEAPONS[level]
		local weaponId = weaponsList[math.random(1, #weaponsList)]
		giveWeapon ( source, weaponId , 2000, true )

		local marker = weaponMarkers[theVehicle]
		destroyElement(marker)
		weaponMarkers[theVehicle] = nil
		weaponSpawnVehicles[theVehicle] = nil

		displayMessageForPlayer ( source, 55, "You got a ".. getWeaponNameFromID(weaponId)..".", 3000)
	end
end
addEventHandler ( "onPlayerVehicleEnter", getRootElement(), enterVehicleToSpawnWeapon )

function removeWeaponInExplodedVehicle()
    local marker = weaponMarkers[source]
	destroyElement(marker)
	weaponMarkers[source] = nil
	weaponSpawnVehicles[source] = nil
end

-- by using getRootElement() as root, it works for any vehicle
addEventHandler("onVehicleExplode", getRootElement(), removeWeaponInExplodedVehicle)

function respawnWeapons(thePlayer, command, spawnPercent)
	WEAPON_PROB = tonumber(spawnPercent)
	outputChatBox("New weapon spawn percentage: "..WEAPON_PROB)

	for k, v in pairs(weaponMarkers) do
	  destroyElement(v)
	end

	spawnWeapons()
end
addCommandHandler("weapon", respawnWeapons)
