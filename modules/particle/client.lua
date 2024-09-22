local entityParticle = {}

local requestTimeouts = GetConvarInt('renewed_requesttimeouts', 10000)

AddStateBagChangeHandler('entityParticle', nil, function(bagName, _, value)
    local entity = GetEntityFromStateBagName(bagName)

    if entity == 0 then return end

    if entityParticle[entity] then
        StopParticleFxLooped(entityParticle[entity], false)
        entityParticle[entity] = nil
    end

    if value and type(value) == 'table' then
        local offset, rotation = value.offset, value.rotation
        lib.requestNamedPtfxAsset(value.dict, requestTimeouts)

        UseParticleFxAsset(value.dict)

        entityParticle[entity] = StartParticleFxLoopedOnEntity(value.effect, entity, offset.x, offset.y, offset.z, rotation.x, rotation.y, rotation.z, value.scale or 1.0, false, false, false)

        RemoveNamedPtfxAsset(value.dict)
    end
end)