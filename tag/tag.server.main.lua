local fallbackSpawnX, fallbackSpawnY, fallbackSpawnZ = 1959.55, -1714.46, 10
local spawnPoints
local theHuntedPlayer
local minPlayers = 1

local HUNTED_MODELS = {167, 140}
local NORMAL_MODELS = {161, 306}
local modelSelectRand = math.random(1,10)
local modelSelectRandIndex = 1
if(modelSelectRand == 1) then
	modelSelectRandIndex = 2
end
local huntedModel = HUNTED_MODELS[modelSelectRandIndex]
local normalModel = NORMAL_MODELS[modelSelectRandIndex]

local RAW_TIME_AS_HUNTED_KEY = "raw.timeAsHunted"
local FORMATTED_TIME_AS_HUNTED_KEY = "Time as Hunted"
local WHOS_HUNTED_TEXT_ID = 1
local itName = "The Chick"
local huntedBlip
local huntedMarker
players = getElementsByType ( "player" )
scoreboardRes = getResourceFromName( "scoreboard" )
voteResource = getResourceFromName( "votemanager" )

function showPlayersWhosHunted()
	local players = getElementsByType ( "player" )
	for k,v in ipairs(players) do
		clearMessageForPlayer ( v, WHOS_HUNTED_TEXT_ID )
		if(v ~= theHuntedPlayer) then
			displayMessageForPlayer ( v, WHOS_HUNTED_TEXT_ID, getPlayerName(theHuntedPlayer).." is "..itName, 999999, 0.5, 0.9, 255, 255, 255, 128, 2 )
		end
	end
	displayMessageForPlayer ( theHuntedPlayer, WHOS_HUNTED_TEXT_ID, "You are "..itName.."!", 999999, 0.5, 0.9, 255, 255, 255, 128, 2 )
end

function setHuntedPlayer(thePlayer)
	removeOldHunted()
	theHuntedPlayer = thePlayer
	showPlayerHudComponent ( theHuntedPlayer, "radar", false )
	setElementModel ( theHuntedPlayer, huntedModel )
	
	if(huntedBlip ~= nil) then
		destroyElement(huntedBlip)
	end
	huntedBlip = createBlipAttachedTo ( theHuntedPlayer, 0 )
	setElementParent ( huntedBlip, theHuntedPlayer )
	
	if(huntedMarker == nil ) then
		huntedMarker = createMarker ( 0, 0, 1, "arrow", 2.0, 255, 0, 0)
	end
	attachElements ( huntedMarker, theHuntedPlayer, 0, 0, 4 )
	showPlayersWhosHunted()
end

function removeOldHunted()
	if( theHuntedPlayer ~= nil) then
		outputDebugString("Removing old Hunted")
		showPlayerHudComponent ( theHuntedPlayer, "radar", true )
		setElementModel ( theHuntedPlayer, normalModel )
		theHuntedPlayer = nil
	end
end

function chooseRandomNewHunted()
	local oldHunted = theHuntedPlayer
	removeOldHunted()
	checkToChooseIt(oldHunted)
end

function chooseNewHuntedBasedOnDistanceTo(thePlayer)
	local players = getElementsByType ( "player" )
	if(#players < minPlayers) then
		return
	end

	local playerX, playerY, playerZ = getElementPosition ( thePlayer )
	
	local playerDistances = {}
	local candidates = {}
	for k,v in ipairs(players) do
		if(v ~= thePlayer) then
			local candX, candY, candZ = getElementPosition ( v )
			local dist = getDistanceBetweenPoints3D (  playerX, playerY, playerZ, candX, candY, candZ )
			outputDebugString("Distance: "..dist)
			table.insert(playerDistances, dist)
			playerDistances[k] = dist
			candidates[k] = v
		end
	end
	
	outputDebugString("Total: "..#playerDistances)
	
	local lowestDist
	local closestPlayer
	for k,dist in ipairs(playerDistances) do
		if(closestPlayer == nil or dist < lowestDist) then
			lowestDist = dist
			closestPlayer = candidates[k]
		end
	end
	
	if(closestPlayer ~= nil) then
		choosePlayerAsHunted(closestPlayer) 
	else
		chooseRandomNewHunted()
	end
end

function choosePlayerAsHunted(thePlayer) 
	removeOldHunted()
	setHuntedPlayer(thePlayer)
end

function checkToChooseIt(oldHunted)
	local players = getElementsByType ( "player" )
	if(#players < minPlayers) then
		outputDebugString("To few players to begin")
		return
	end

	if(theHuntedPlayer ~= nil) then
		outputDebugString("Hunted is already "..getPlayerName(theHuntedPlayer))
		return
	end
	
	if(oldHunted ~= nil) then
		playersWithoutOld = {}
		for k,v in ipairs(players) do
			if(v ~= oldHunted) then
				outputDebugString("Added "..getPlayerName(v).." to available")
				table.insert(playersWithoutOld, v)
			end
		end
		if(#playersWithoutOld > 0) then
			players = playersWithoutOld
		end
	end
	
	setHuntedPlayer(players[math.random(1,#players)])
	outputDebugString(itName.." is now "..getPlayerName(theHuntedPlayer).."!")
	outputChatBox(itName.." is now "..getPlayerName(theHuntedPlayer).."!")
end

function doResetGame() 
	outputDebugString("Resetting game!")
	removeOldHunted()
	local players = getElementsByType ( "player" )
	for k,v in ipairs(players) do
		setElementData( v, RAW_TIME_AS_HUNTED_KEY , 0)
		setElementData( v, FORMATTED_TIME_AS_HUNTED_KEY , 0)
	end
	chooseRandomNewHunted()
end

function givePointsToIt()
	local players = getElementsByType ( "player" )
	if(theHuntedPlayer ~= nil and #players > 0) then
		local totalTime = getElementData( theHuntedPlayer, RAW_TIME_AS_HUNTED_KEY )
		if(totalTime == false) then
			totalTime = 0
		end
		totalTime = totalTime + 1
		local minutes = math.floor(totalTime / 60)
		local seconds = totalTime % 60
		setElementData( theHuntedPlayer, RAW_TIME_AS_HUNTED_KEY , totalTime)
		setElementData( theHuntedPlayer, FORMATTED_TIME_AS_HUNTED_KEY , minutes..":"..seconds)
	end
end
setTimer(givePointsToIt, 1000, 0)

function damageItsCar()
	if(theHuntedPlayer ~= nil) then
		local theVehicle = getPedOccupiedVehicle ( theHuntedPlayer )
		if theVehicle then
			local health = getElementHealth(theVehicle)
			if(health > 1000) then
				health = 950
			elseif(health < 650) then
				health = health - 30
			else
				health = health - 50
			end
			setElementHealth ( theVehicle, health )
		end
	end
end
setTimer(damageItsCar, 5000, 0)

function respawnAllPlayers()
	local players = getElementsByType ( "player" )
	for k,v in ipairs(players) do
		spawn ( v )
	end
end

function startTagGameMap( startedMap )
	local mapRoot = getResourceRootElement( startedMap ) 
    spawnPoints = getElementsByType ( "spawnpoint" , mapRoot )
	respawnAllPlayers()
	checkToChooseIt()
end
addEventHandler("onGamemodeMapStart", getRootElement(), startTagGameMap)

function onEventGamemodeStart ()
	checkToChooseIt()
end
addEventHandler("onGamemodeStart" , getRootElement(), onEventGamemodeStart)

function joinHandler()
	spawn(source)
	outputChatBox("Welcome to My Server", source)
	setElementModel ( source, normalModel )
	setTimer(checkToChooseIt, 5000, 1)
end
addEventHandler("onPlayerJoin", getRootElement(), joinHandler)

function playerSpawnHandler()
	local model = normalModel
	if(source == theHuntedPlayer) then
		model = huntedModel
	end
	setElementModel ( source, model )
end
addEventHandler("onPlayerSpawn", getRootElement(), playerSpawnHandler)

function leaveHandler()
	theHuntedPlayer = nil
	local chooseNew = thePlayer == theHuntedPlayer
	setTimer(function(thePlayer) 
		if(chooseNew) then
			chooseRandomNewHunted()
		end
	end, 2000, 1, source)
end
addEventHandler ( "onPlayerQuit", getRootElement(), leaveHandler )

function spawn(thePlayer)
	local spawnX, spawnY, spawnZ
	if(spawnPoints == nil) then
		spawnX = fallbackSpawnX
		spawnY = fallbackSpawnY
		spawnZ = fallbackSpawnZ
	else
		spawnX, spawnY, spawnZ = getRandomSpawnPoint()
	end
	
	spawnPlayer(thePlayer, spawnX, spawnY, spawnZ, 0, normalModel)
	fadeCamera(thePlayer, true)
	setCameraTarget(thePlayer, thePlayer)
end

function getRandomSpawnPoint ()
	local point = spawnPoints[math.random(1,#spawnPoints)]
	local posX = getElementData ( point, "posX" )
	local posY = getElementData ( point, "posY" )
	local posZ = getElementData ( point, "posZ" )
	return posX, posY, posZ
end

function playerDied( ammo, attacker, weapon, bodypart )
	local killer
	if ( attacker ) then
		if ( getElementType ( attacker ) == "player" ) then
			killer = attacker
		elseif ( getElementType ( attacker ) == "vehicle" ) then
			-- we'll get the name from the attacker vehicle's driver
			killer = getVehicleController ( attacker ) 
		end
	end
	
	if(source == theHuntedPlayer) then
		if( killer ~= source and killer ~= nil ) then
			outputChatBox(itName.." was killed by "..getPlayerName(killer))
			choosePlayerAsHunted(killer)
		else
			outputChatBox(itName.." failed to live")
			chooseNewHuntedBasedOnDistanceTo(source)
		end
	end
	
	setTimer( spawn, 2000, 1, source)
end
addEventHandler( "onPlayerWasted", getRootElement( ), playerDied)

function createVehicleForPlayer(thePlayer, command, vehicleModel)
	local model = math.random(420,600)
	local x,y,z = getElementPosition(thePlayer) -- get the position of the player
	x = x + 5 -- add 5 units to the x position
	local createdVehicle = createVehicle(tonumber(vehicleModel),x,y,z)
	-- check if the return value was ''false''
	if (createdVehicle == false) then
		-- if so, output a message to the chatbox, but only to this player.
		outputChatBox("Failed to create vehicle.",thePlayer)
	end
end
addCommandHandler("c", createVehicleForPlayer)

function commitSuicide ( sourcePlayer )
	-- kill the player and make him responsible for it
	killPed ( sourcePlayer, sourcePlayer )
end
addCommandHandler ( "kill", commitSuicide )


addEventHandler("onPollEnded",getResourceRootElement(voteResource),
function(msg)
	outputDebugString("wegwwegw")
end )

function resetGame()
	local notEnoughVotesMessage = "Not enough votes to reset."
	local voteData = {
		--start settings (dictionary part)
		title="Reset game?",
		percentage=75,
		timeout=30,
		allowchange=false,
		maxnominations=3,
		visibleTo=getRootElement(),
		[1]={"Yes", "onResetGame"},
		[2]={"No", "onResetGame", getRootElement(), notEnoughVotesMessage}
	}
	--exports.votemanager:startPoll(voteData)
	call(voteResource,"startPoll", voteData)
end
addCommandHandler( "reset", resetGame )

addEventHandler("onResetGame",getRootElement(),
function()
	outputDebugString("Resetting game!")
end )

addEventHandler("onResourceStop",getResourceRootElement(getThisResource()),
function()
	call(scoreboardRes,"removeScoreboardColumn",FORMATTED_TIME_AS_HUNTED_KEY)
end )

addEventHandler("onResourceStart",getResourceRootElement(getThisResource()),
function()
	call(scoreboardRes,"addScoreboardColumn",FORMATTED_TIME_AS_HUNTED_KEY)
end )

function getTheHunted()
	return theHuntedPlayer
end

function displayMessageForPlayer ( player, ID, message, displayTime, posX, posY, r, g, b, alpha, scale )
	assert ( player and ID and message )
	local easyTextResource = getResourceFromName ( "easytext" )
	displayTime = displayTime or 5000
	posX = posX or 0.5
	posY = posY or 0.5
	r = r or 255
	g = g or 127
	b = b or 0
	-- display message for everyone
	outputConsole ( message, player )
	call ( easyTextResource, "displayMessageForPlayer", player, ID, message, displayTime, posX, posY, r, g, b, alpha, scale )
end

function clearMessageForPlayer ( player, ID )
	assert ( player and ID )
	call ( getResourceFromName ( "easytext" ), "clearMessageForPlayer", player, ID )
end