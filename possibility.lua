do -- Possibility
	Possibility = {}

	function Possibility.New(values)
		return setmetatable({
			values = values
		}, Possibility)
	end

	function Possibility:GetRandomValue()
		local values = self.values
		return values[math.random(1, #values)]
	end

	function Possibility:__tostring()
		local t = {}

		for k, v in ipairs(self.values) do
			t[#t + 1] = tostring(v)
		end

		return "Possibility[" .. table.concat(t, ",") .. "]"
	end

	function Possibility:__mul(other)
		local t = {}

		for k, v in ipairs(self.values) do
			for k2, v2 in ipairs(other.values) do
				t[#t + 1] = v * v2
			end
		end

		return Possibility(t)
	end

	function Possibility:__pow(n)
		if n == 0 then
			return Possibility({1})
		elseif n == 1 then
			return self
		else
			return self * (self ^ (n - 1))
		end
	end

	Possibility.__index = Possibility

	setmetatable(Possibility, {
		__call = function(_, ...) return Possibility.New(...) end
	})
end

do -- MulSum, helper for Possibility
	MulSum = {}

	function MulSum.New(mul,sum)
		if isstring(sum) then
			sum = AddString(sum)
		end

		return setmetatable({
			mul, -- a value that can be multiplied
			sum, -- a value that can be added
		}, MulSum)
	end

	local fmt = "[%s,%s]"
	function MulSum:__tostring()
		return string.format(fmt, self[1], self[2])
	end

	function MulSum:__mul(other)
		return MulSum(self[1] * other[1], self[2] + other[2])
	end

	setmetatable(MulSum, {
		__call = function(_, ...) return MulSum.New(...) end
	})
end

do -- AddString, helper for when you don't want to just do getmetatable("").__add = function(a,b) return a..b end
	AddString = {}

	function AddString.New(str)
		return setmetatable({
			str
		}, AddString)
	end

	function AddString:__tostring()
		return self[1]
	end

	function AddString:__add(other)
		return AddString(self[1] .. other[1])
	end

	setmetatable(AddString, {
		__call = function(_, ...) return AddString.New(...) end
	})
end

-- Examples:

-- local totally_not_a_coin = Possibility({0.5,0.5})^3
-- print(totally_not_a_coin) -- output: Possibility[0.125,0.125,0.125,0.125,0.125,0.125,0.125,0.125]
-- print(totally_not_a_coin:GetRandomValue()) -- output: 0.125

-- Chance = MulSum -- alias

-- local heads = Chance(0.5,"H")
-- local tails = Chance(0.5,"T")
-- local coin = Possibility({heads,tails})^3

-- print(coin) -- Possibility[[0.125,HHH],[0.125,HHT],[0.125,HTH],[0.125,HTT],[0.125,THH],[0.125,THT],[0.125,TTH],[0.125,TTT]]
-- print(coin:GetRandomValue()) -- [0.125,THT] or any other value from above