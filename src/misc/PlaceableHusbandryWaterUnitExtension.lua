-- @author: 4c65736975, All Rights Reserved
-- @version: 1.0.0.0, 13|04|2023
-- @filename: PlaceableHusbandryWaterUnitExtension.lua

PlaceableHusbandryWaterUnitExtension = {}

local PlaceableHusbandryWaterUnitExtension_mt = Class(PlaceableHusbandryWaterUnitExtension)

---Creating PlaceableHusbandryWaterUnitExtension instance
---@param additionalUnits table additionalUnits object
---@param fillTypeManager table fillTypeManager object
---@return table instance instance of object
function PlaceableHusbandryWaterUnitExtension.new(customMt, additionalUnits, fillTypeManager)
	local self = setmetatable({}, customMt or PlaceableHusbandryWaterUnitExtension_mt)

	self.additionalUnits = additionalUnits
	self.fillTypeManager = fillTypeManager

	return self
end

---Initializing PlaceableHusbandryWaterUnitExtension
function PlaceableHusbandryWaterUnitExtension:initialize()
	self.additionalUnits:overwriteGameFunction(PlaceableHusbandryWater, 'getConditionInfos', function (_, husbandry, superFunc)
		local infos = superFunc(husbandry)
		local spec = husbandry.spec_husbandryWater

		local info = {}
		local fillType = self.fillTypeManager:getFillTypeByIndex(spec.fillType)
		local capacity = husbandry:getHusbandryCapacity(spec.fillType)
		local ratio = 0

		info.title = fillType.title
		info.fillType = fillType.name
		info.value = husbandry:getHusbandryFillLevel(spec.fillType)

		if capacity > 0 then
			ratio = info.value / capacity
		end

		info.ratio = MathUtil.clamp(ratio, 0, 1)
		info.invertedBar = true

		table.insert(infos, info)

		return infos
	end)

	self.additionalUnits:overwriteGameFunction(PlaceableHusbandryWater, 'updateInfo', function (_, husbandry, superFunc, infoTable)
		superFunc(husbandry, infoTable)

		local spec = husbandry.spec_husbandryWater
		local fillLevel = husbandry:getHusbandryFillLevel(spec.fillType)
		local formattedFillLevel, unit = self.additionalUnits:formatFillLevel(fillLevel, self.fillTypeManager:getFillTypeNameByIndex(spec.fillType), 0)

		spec.info.text = formattedFillLevel .. ' ' .. unit

		table.insert(infoTable, spec.info)
	end)
end