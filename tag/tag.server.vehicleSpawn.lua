local VERY_CLOSE_VEHICLE_DIST = 15
local CLOSE_VEHICLE_DIST = 50
local MAX_VEHICLES_IN_CLOSE = 5

spawnBeams = {}
noSpawnMarkers = {}

function finishVehicleSpawn(newVehicle, beam, thePlayer)
	--setVehicleDamageProof(newVehicle, false)
	--setElementCollisionsEnabled(newVehicle, true)
	--setElementAlpha(newVehicle, 255)
	createVehicleSpawnBeam(thePlayer)
end

function spawnVechicleInBeam(beam, thePlayer)
	local x,y,z = getElementPosition(beam)
	local newVehicle = createVehicle(math.random(400,610), x, y, z + 2)
	if(newVehicle) then
		--setVehicleDamageProof(newVehicle, true)
		--setElementCollisionsEnabled(newVehicle, false)
		--setElementAlpha(newVehicle, 128)
		destroySpawnBeam(thePlayer)
		setTimer(finishVehicleSpawn, 2000, 1, newVehicle, beam, thePlayer)
	else
		createVehicleSpawnBeam(thePlayer)
	end
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

function createVehicleSpawnBeam(thePlayer)
	if(getPedOccupiedVehicle(thePlayer) == false) then
		local x,y,z = getElementPosition(thePlayer)
		if(vehiclesToClose(x,y,z)) then
			setTimer(createVehicleSpawnBeam, 3000, 1, thePlayer)
			return
		end
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
	end
end

function playerExitedVehicleForVehicleBeam()
	setTimer(createVehicleSpawnBeam, 3000, 1, source)
end
addEventHandler("onPlayerVehicleExit", getRootElement(), playerExitedVehicleForVehicleBeam)

function onPlayerSpawnForVehicleBeam()
	setTimer(createVehicleSpawnBeam, 5000, 1, source)
end
addEventHandler("onPlayerSpawn", getRootElement(), onPlayerSpawnForVehicleBeam)

function onPlayerJoinForVehicleBeam()
	bindKey ( source, "x", "down", cancelVehicleButtonPressed ) 
end
addEventHandler("onPlayerJoin", getRootElement(), onPlayerJoinForVehicleBeam)



