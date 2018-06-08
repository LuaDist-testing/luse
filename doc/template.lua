module(..., package.seeall)

function print(...)
	for i=1,select('#', ...) do
		if i~=1 then io.write("\t") end
		io.write(tostring(select(i, ...)))
	end
end

