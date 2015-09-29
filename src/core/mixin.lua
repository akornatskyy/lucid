local next = next

--[[
    Merge the contents of two or more tables together into the first.
--]]
return function(cls, ...)
	for _, mixin in next, {...} do
		for name, method in next, mixin do
			cls[name] = method
		end
	end
    return cls
end
