local VERY_CLOSE_VEHICLE_DIST = 15
local CLOSE_VEHICLE_DIST = 50
local MAX_VEHICLES_IN_CLOSE = 5
local RELOAD_TIME = 5000

local allAircrafts = { [592]=true, [577]=true, [511]=true, [548]=true, [512]=true, [593]=true, [425]=true, [520]=true, [417]=true, [487]=true, [553]=true, [488]=true, [497]=true,
[563]=true, [476]=true, [447]=true, [519]=true, [460]=true, [469]=true, [513]=true }

local allBoats = { [472]=true, [473]=true, [493]=true, [595]=true, [484]=true, [430]=true, [453]=true, [452]=true, [446]=true, [454]=true, [539]=true }

spawnBeams = {}
noSpawnMarkers = {}
lastSpawnTime = {}

function finishVehicleSpawn(newVehicle, beam, thePlayer)
	--setVehicleDamageProof(newVehicle, false)
	--setElementCollisionsEnabled(newVehicle, true)
	--setElementAlpha(newVehicle, 255)
	--createVehicleSpawnBeam(thePlayer)
end

function spawnVechicleInBeam(beam, thePlayer)
	local x,y,z = getElementPosition(beam)
	local newVehicle = createVehicle(randomVehicleModel(), x, y, z + 2)
	if(newVehicle) then
		--setVehicleDamageProof(newVehicle, true)
		--setElementCollisionsEnabled(newVehicle, false)
		--setElementAlpha(newVehicle, 128)
		destroySpawnBeam(thePlayer)
		setTimer(finishVehicleSpawn, 2000, 1, newVehicle, beam, thePlayer)
	else
		--createVehicleSpawnBeam(thePlayer)
	end
end

function randomVehicleModel()
	local modelId = -1
	while modelId < 0 do
		modelId = math.random(400,610)
		if (allAircrafts[modelId] or allBoats[modelId]) then
			modelId = -1
		end
	end
	return modelId
end

function vehiclesToClose(x, y, z)
	local vehicles = getElementsByType ( "vehicle" )
	local nbrClose, nbrVeryClose = 0
	for k,v in ipairs(vehicles) do
		local vX, vY, vZ = getElementPosition(v)
		local distX = math.abs(x - vX)
		local distY = math.abs(y - vY)
		if(distX > CLOSE_VEHICLE_DIST or distY > CLOSE_VEHICLE_DIST) then

		elseif(distX > VERY_CLOSE_VEHICLE_DIST or distY > VERY_CLOSE_VEHICLE_DIST) then
			nbrClose = nbrClose + 1
			if(nbrClose >= MAX_VEHICLES_IN_CLOSE) then
				return true
			end
		else
			return true
		end
	end

	return false
end

function noSpawnMarkerLeave( leaveElement, matchingDimension )
	if (getElementType( leaveElement ) == "player") then
		if(noSpawnMarkers[getPlayerIP(leaveElement)] == source) then
			destroyElement(noSpawnMarkers[getPlayerIP(leaveElement)])
			noSpawnMarkers[getPlayerIP(leaveElement)] = nil
			setTimer(createVehicleSpawnBeam, 3000, 1, leaveElement)
		end
	end
end

function destroySpawnBeam(thePlayer)
	local spawnBeam = spawnBeams[getPlayerIP(thePlayer)]
	if(spawnBeam) then
		destroyElement(spawnBeam.beam)
		destroyElement(spawnBeam.timerMarker)
		killTimer(spawnBeam.spawnTimer)
		killTimer(spawnBeam.timerMarkerTimer)
		spawnBeams[getPlayerIP(thePlayer)] = nil
	end
end

function cancelVehicleButtonPressed(thePlayer, key, keyState)
	destroySpawnBeam(thePlayer)
	if(noSpawnMarkers[getPlayerIP(thePlayer)] == nil) then
		local x,y,z = getElementPosition(thePlayer)
		local noSpawnMarker = createMarker ( x, y, z , "checkpoint", 20.0, 0, 0, 0, 0)
		noSpawnMarkers[getPlayerIP(thePlayer)] = noSpawnMarker
		addEventHandler( "onMarkerLeave", noSpawnMarker, noSpawnMarkerLeave )
	end
end

function removeFarAwayCars(x, y, z)
	local cars = getElementsByType("vehicle")
	local allCars = getValidVehicleModels ()

	for i,car in ipairs(cars) do
		if not car then
			if isCarEmpty(car) then
				destroyElement(car)
			end
		end
end

function isCarEmpty(car)
	local counter = 0

	for seat, player in pairs(getVehicleOccupants(car)) do
	    counter = counter + 1
	end

	return counter == 0
end

function vehicleRain(thePlayer)
	local x,y,z = getElementPosition(thePlayer)
	local allCars = getValidVehicleModels ()
	removeFarAwayCars(x, y, z)

	x = x - 50
	y = y - 50
	for i=0, 100, 10 do
		for j=0, 100, 10 do
			posX = x + i
			posY = y + j
			posZ = z + 100

			local carIndex = math.random(1, #allCars)
			local carId = allCars[carIndex]

			local vehicle =  createVehicle(carId, posX, posY, posZ, 0, 0, 0, "Rain")
			setTimer(function()
	      setElementVelocity(vehicle, 10, 0, 0);
	    end, 100, 1)
			setElementVelocity(vehicle, 10, 0, 0);
		end
	end
end

function createVehicleSpawnBeam(thePlayer)
	if (thePlayer == getTheHunted()) then
		vehicleRain(thePlayer)
	elseif(getPedOccupiedVehicle(thePlayer) == false) then

		local lastSpawn = lastSpawnTime[thePlayer]
		if (lastSpawn ~= nil and (getTickCount() - lastSpawn) < RELOAD_TIME) then
			return
		end

		local x,y,z = getElementPosition(thePlayer)
		--if(vehiclesToClose(x,y,z)) then
		--	setTimer(createVehicleSpawnBeam, 3000, 1, thePlayer)
		--	return
		--end
		local beamX = x + math.random(0,0)-0
		local beamY = y + math.random(0,0)-0
		local arrowStartHeight = 2
		local arrowStopHeight = -0.5
		local beam = createMarker ( beamX, beamY, z , "checkpoint", 0.2, 255, 255, 255)
		local spawnTime = math.random(3000,5000)
		local changeInterval = 200
		local changes = spawnTime / changeInterval
		local arrowSteps = (arrowStartHeight - arrowStopHeight) / changes
		local timerMarker = createMarker ( beamX, beamY, z + arrowStartHeight - arrowSteps, "arrow", 0.4, 0, 0, 0)
		--local colorChange = 255 / changes
		--setTimer(function(beam, colorChange)
		--	local R, G, B, A = getMarkerColor( beam )
		--	setMarkerColor ( beam, R, G+colorChange, B+colorChange, 255 )
		--end, changeInterval, changes, beam, colorChange)

		local timerMarkerTimer = setTimer(function(timerMarker, arrowSteps)
			local x,y,z = getElementPosition(timerMarker)
			setElementPosition(  timerMarker, x, y, z - arrowSteps)
		end, changeInterval, changes, timerMarker, arrowSteps)

		local spawnTimer = setTimer(spawnVechicleInBeam, spawnTime, 1, beam, thePlayer)
		local spawnBeam = {beam = beam, timerMarker = timerMarker, timerMarkerTimer = timerMarkerTimer, spawnTimer = spawnTimer}
		spawnBeams[getPlayerIP(thePlayer)] = spawnBeam
		lastSpawnTime[thePlayer] = getTickCount()
	end
end

function mixStuff()
	changeVehicleModels()
	changePickups()
end

function changePickups()
	local pickups = getElementsByType("pickup")

	for i,pickup in ipairs(pickups) do
		if getPickupType ( pickup ) == 2 then
			local weapon = getPickupWeapon ( pickup )

			local otherPickup = math.random(1, 10)
			if otherPickup <= 1 then
				setPickupType ( pickup, math.random(0, 1), 100 )
			else

				if weapon == 22 then -- Normal pickup
					local newWeapon = math.random(25, 33)
					setPickupType ( pickup, 2, newWeapon, 1000 )
				else -- Super weapon
					local newWeapon = math.random(34, 38)
					setPickupType ( pickup, 2, newWeapon, 100 )
				end
			end
  	end
	end
end

function changeVehicleModels()
	outputDebugString("Mixing cars")
	local cars = getElementsByType("vehicle")
	local allCars = getValidVehicleModels ()

	for i,car in ipairs(cars) do
		if not car then
			outputDebugString("Null car")
			return
		end
		local carIndex = math.random(1, #allCars)
		local carId = allCars[carIndex]
		setElementModel (car, carId)
	end
end

function getValidVehicleModels ( )
	local validVehicles = { }
	local invalidModels = {
		['435']=true, ['449']=true, ['450']=true, ['537']=true,
		['538']=true, ['569']=true, ['570']=true, ['584']=true,
		['590']=true, ['591']=true, ['606']=true, ['607']=true,
		['608']=true
	}
	local allAircrafts = {
		[592]=true, [577]=true, [511]=true, [548]=true, [512]=true,
		[593]=true, [425]=true, [520]=true, [417]=true, [487]=true,
		[553]=true, [488]=true, [497]=true, [563]=true, [476]=true,
		[447]=true, [519]=true, [460]=true, [469]=true, [513]=true
	}

	local allBoats = {
		[472]=true, [473]=true, [493]=true, [595]=true, [484]=true,
		[430]=true, [453]=true, [452]=true, [446]=true, [454]=true,
		[539]=true
	}

	local rcVehicles = {
		[441]=true, [464]=true, [594]=true, [501]=true, [465]=true, [564]=true
	}

	for i=400, 609 do
		if ( not (invalidModels[i] or allAircrafts[i] or allBoats[i] or rcVehicles[i])) then
			table.insert ( validVehicles, i )
		end
	end
	return validVehicles
end

addEventHandler("onGamemodeMapStart", getRootElement(), mixStuff)

function playerExitedVehicleForVehicleBeam()
	--setTimer(createVehicleSpawnBeam, 3000, 1, source)
end
addEventHandler("onPlayerVehicleExit", getRootElement(), playerExitedVehicleForVehicleBeam)

function onPlayerSpawnForVehicleBeam()
	--setTimer(createVehicleSpawnBeam, 5000, 1, source)
end
addEventHandler("onPlayerSpawn", getRootElement(), onPlayerSpawnForVehicleBeam)

function onPlayerJoinForVehicleBeam()
	--bindKey ( source, "x", "down", cancelVehicleButtonPressed )
	bindKey ( source, "x", "down", createVehicleSpawnBeam )
end
addEventHandler("onPlayerJoin", getRootElement(), onPlayerJoinForVehicleBeam)
