local MAP_LIMITS

function startTagGameMap( startedMap )
	MAP_LIMITS = limitPoints();
end
addEventHandler("onGamemodeMapStart", getRootElement(), startTagGameMap)

function limitPoints()
	mapLimits = {}
	local groups = getElementsByType ( "maplimit" )
	for k,v in ipairs(groups) do
		mapLimits = {}
		local points = getChildren ( v, "point" )
		for i,j in ipairs(points) do
			mapLimits[i] = {}
			mapLimits[i].x = tonumber(getElementData( j, "x" ))
			mapLimits[i].y = tonumber(getElementData( j, "y" ))
		end
	end

  return mapLimits
end

function getChildren ( root, type )
	local elements = getElementsByType ( type )
	local result = {}
	for elementKey,elementValue in ipairs(elements) do
		if ( getElementParent( elementValue ) == root ) then
			result[ table.getn( result ) + 1 ] = elementValue
		end
	end
	return result
end

addEvent("onClientResourceStarted", true)
addEventHandler("onClientResourceStarted", getRootElement(), function()
	triggerClientEvent ( "onMapLimitsRespone", getRootElement(), MAP_LIMITS )
end)