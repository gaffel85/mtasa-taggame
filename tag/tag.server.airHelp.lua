local aircrafts = { [592]=true, [577]=true, [511]=true, [548]=true, [512]=true, [593]=true, [425]=true, [520]=true, [417]=true, [487]=true, [553]=true, [488]=true, [497]=true,
[563]=true, [476]=true, [447]=true, [519]=true, [460]=true, [469]=true, [513]=true }

local boats = { [472]=true, [473]=true, [493]=true, [595]=true, [484]=true, [430]=true, [453]=true, [452]=true, [446]=true, [454]=true, [539]=true }


local STATE_LAND = 0
local STATE_AIR = 1
local STATE_SEA = 2

local PRIMARY_AIR = 520
local SECONDARY_AIR = 476
local PRIMARY_SEA = 447
local SECONDARY_SEA = 430
local PRIMARY_VEHICLE = {[STATE_AIR] = PRIMARY_AIR, [STATE_SEA] = PRIMARY_SEA}
local SECONDARY_VEHICLE = {[STATE_AIR] = SECONDARY_AIR, [STATE_SEA] = SECONDARY_SEA}

local FALL_MODEL = 461

local DROP_X = -2410.1000976563
local DROP_Y = -369.5
local DROP_Z = 257.90002441406
local DROP_DIST = 5

local FADE_TIME = 1.0
local INSTR_AIR = " is in the air. Take him down!\nPress 8 to get a fighter jet\nPress 9 to get a plane with guns"
local INSTR_SEA = " is wet. Take him down!\nPress 8 to get a helicopter\nPress 9 to get a police boat with guns"
local INSTR = {[STATE_AIR] = INSTR_AIR, [STATE_SEA] = INSTR_SEA}
local INSTR_ID = 677

local PARACHUTE_INSTR_ID = 687
local PARACHUTE_INSTR = "God job! Now, enjoy the fall."

local KILL_ON_WATER = true

local testMode = false
local state = STATE_LAND
local stupidPlayer

function transformToJet(thePlayer, key, keyState)
	transformToVehicle(thePlayer, PRIMARY_VEHICLE[state])
end

function transformToBarone(thePlayer, key, keyState)
	transformToVehicle(thePlayer, SECONDARY_VEHICLE[state])
end

function transformToVehicle(thePlayer, planeModel)
	if(state ~= STATE_LAND) then
		local theVehicle = getPedOccupiedVehicle ( thePlayer )
		if theVehicle then
			setElementModel(theVehicle, planeModel)
			setVehicleLandingGearDown(theVehicle, true)
		end
	end
end

function checkAndSetAirState(thePlayer, vehicle)
	if(state == STATE_AIR or vehicle == nil or thePlayer ~= getTheHunted()) then
		return false
	end

	if(aircrafts[getElementModel ( vehicle )]) then
		state = STATE_AIR
		return true
	end

	return false
end

function checkAndSetLandState(thePlayer, vehicle)
	if(state == STATE_SEA or thePlayer ~= getTheHunted()) then
		return false
	end

	if(isElementInWater(thePlayer)) then
		state = STATE_SEA
		return true
	end

	if(vehicle ~= nil and boats[getElementModel ( vehicle )]) then
		state = STATE_SEA
		return true
	end

	return false
end

function checkToChangeState(thePlayer, vehicle)

	if(thePlayer == nil or thePlayer ~= getTheHunted()) then
		return
	end
	
  if KILL_ON_WATER then
    if(isElementInWater(thePlayer) or
       vehicle ~= nil and (
         boats[getElementModel ( vehicle )] or
         aircrafts[getElementModel ( vehicle )]
       )
     ) then
      killPed ( thePlayer, thePlayer )
    end
    return
  end

	local changed = checkAndSetAirState(thePlayer, vehicle)
	if(changed ~= true) then
		changed = checkAndSetLandState(thePlayer, vehicle)
	end

	if(changed) then
		stupidPlayer = thePlayer

		local players = getElementsByType ( "player" )
		for k,v in ipairs(players) do
			if(testMode or v ~= stupidPlayer) then
				displayMessageForPlayer ( v, INSTR_ID, getPlayerName(stupidPlayer)..INSTR[state], 5000 )
				bindKey ( v, "8", "down", transformToJet )
				bindKey ( v, "9", "down", transformToBarone )
			end
		end
	end
end

function enterVehicleCheckAirHelp ( thePlayer, seat, jacked )
	checkToChangeState(thePlayer, source)
end
addEventHandler ( "onVehicleEnter", getRootElement(), enterVehicleCheckAirHelp )

function givePlayerParachute(thePlayer)
	displayMessageForPlayer ( thePlayer, PARACHUTE_INSTR_ID, PARACHUTE_INSTR, 5000 )
end

function getDropCoords(players, index)
	local side = math.floor(math.sqrt(#players))
	local row = math.floor(index / side)
	local col = index - row * side
	return DROP_X + col*DROP_DIST, DROP_Y + row*DROP_DIST, DROP_Z
end

function stupidPlayerDied( ammo, attacker, weapon, bodypart )
  if KILL_ON_WATER then
    return
  end

	if(source == stupidPlayer) then
		state = STATE_LAND
		local players = getElementsByType ( "player" )
		local index = 0
		for k,v in ipairs(players) do
			if(testMode or v ~= stupidPlayer) then
				unbindKey ( v, "8", "down", transformToJet )
				unbindKey ( v, "9", "down", transformToBarone )
				fadeCamera ( v, false, FADE_TIME )
				setTimer(function(thePlayer, players, index)
					local x,y,z = getDropCoords(players, index)
					local bike = createVehicle ( FALL_MODEL, x, y, z)
					warpPedIntoVehicle ( thePlayer,bike)
					fadeCamera ( thePlayer, true, FADE_TIME )
				end, FADE_TIME * 2* 1000, 1, v, players, index)
				--setTimer(givePlayerParachute, FADE_TIME * 3 * 1000, 1, v)
				givePlayerParachute(v)
				index = index + 1
			end

		end
		stupidPlayer = nil
	end
end
addEventHandler( "onPlayerWasted", getRootElement( ), stupidPlayerDied)

function checkInWater()
	checkToChangeState(getTheHunted(), nil)
end
setTimer(checkInWater, 5000, 99999999)
