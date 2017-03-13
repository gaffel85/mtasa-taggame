local MAP_LIMITS = {}

function drawMapLimitFence()
  MAP_LIMITS = limitPoints();
  addEventHandler("onClientRender", root, createFence)        -- onClientRender keeps the 3D Line visible.
end

function limitPoints()
  mapLimits = {}
	local groups = getElementsByType ( "maplimit" )
	for k,v in ipairs(groups) do
		mapLimits[k] = {}
		local points = getChildren ( v, "point" )
		for i,j in ipairs(points) do
			mapLimits[k][i] = {}
			mapLimits[k][i].x = tonumber(getElementData( j, "x" ))
			mapLimits[k][i].y = tonumber(getElementData( j, "y" ))
		end
	end

  retur  mapLimits;
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

function createFence ( )
  local last = nil
  local zStart = 1
  local zStop = 50
  local zSteps = 2
  for k,v in ipairs(groups) do
    if last ~= nil then
      for i=zStart, zStop, zSteps do
        dxDrawLine3D ( last.x, last.y, i, v.x, v.y, i, tocolor ( 255, 0, 0, 128 ), 4)
      end
    end
    last = v
  end
end
addCommandHandler("test", makeLineAppear)

addEventHandler("onGamemodeMapStart", getRootElement(), drawMapLimitFence)
