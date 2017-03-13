local MAP_LIMITS = {}

function drawMapLimitFence()
	addEventHandler("onClientRender", root, createFence)        -- onClientRender keeps the 3D Line visible.
end

local dl = 0
local dls = 0.3
local zStart = 1
local zStop = 50
local zSteps = 15
function createFence ( )
  local last = nil
  for k,v in ipairs(MAP_LIMITS) do
    if last == nil then
	  last = MAP_LIMITS[#MAP_LIMITS]
	end
    
	for i=zStart, zStop, zSteps do
      dxDrawLine3D ( last.x, last.y, i + dl, v.x, v.y, i + dl, tocolor ( 255, 0, 0, 128 ), 50)
    end
    
    last = v
  end

  dl = dl + dls
  if dl >= zSteps then
	dl = 0
  end
end

addEvent("onMapLimitsRespone", true)
addEventHandler("onMapLimitsRespone", getRootElement(), function(mapLimits)
	MAP_LIMITS = mapLimits
	drawMapLimitFence()
end)

triggerServerEvent ( "onClientResourceStarted", resourceRoot )
