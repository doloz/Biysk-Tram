local Colors = {
	LABEL_BLACK = "FE0000"
}

function numberFrom2HexDigits(hexDigits)
	local hex = "0123456789ABCDEF"
	local first, second = hex:find(hexDigits:sub(1, 1)) - 1, hex:find(hexDigits:sub(2, 2)) - 1
	return 16 * first + second
end

function colorsFromHex(hexString)
	assert(hexString, "Пустая строка с цветом")
	local resultTable = {}
	for i = 1, #hexString - 1, 2 do
		local twoHex = hexString:sub(i, i + 1)
		local number = numberFrom2HexDigits(twoHex) / 255
		table.insert(resultTable, number)
	end
	return unpack(resultTable)
end

-- setmetatable(Colors, {
-- 	__call = function (c, id) 
-- 		if c[id] then
-- 			return colorsFromHex(c[id])
-- 		else
-- 			error("No such color " .. id)
-- 		end
-- 	end
-- })

local ColorsProxy = {}
setmetatable(ColorsProxy, {
	__index = function (t, i)
		return colorsFromHex(Colors[i])
	end,
	__newindex = function ()
		error("Нельзя добавлять новые цвета")
	end
})

return ColorsProxy