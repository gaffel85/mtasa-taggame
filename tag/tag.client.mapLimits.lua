local MAP_LIMITS = {}

function drawMapLimitFence()
	addEventHandler("onClientRender", root, createFence)        -- onClientRender keeps the 3D Line visible.
end


function createFence ( )
  local last = nil
  local zStart = 1
  local zStop = 50
  local zSteps = 4
  for k,v in ipairs(MAP_LIMITS) do
    if last ~= nil then
      for i=zStart, zStop, zSteps do
        dxDrawLine3D ( last.x, last.y, i, v.x, v.y, i, tocolor ( 255, 0, 0, 128 ), 50)
      end
    end
    last = v
  end
end

addEvent("onMapLimitsRespone", true)
addEventHandler("onMapLimitsRespone", getRootElement(), function(mapLimits)
	MAP_LIMITS = mapLimits
	drawMapLimitFence()
end)

triggerServerEvent ( "onClientResourceStarted", resourceRoot )
