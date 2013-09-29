--------------------------------------------------------------
-- FileName: 	util.lua
-- author:		
-- purpose:		³£ÓÃº¯Êý
--------------------------------------------------------------


function dump_obj(obj, with_meta_table)
	print(); print( "~~~~~~~~~~ dump obj table ~~~~~~~~~~~");

	local t = obj; print(t);
	for k,v in pairs(t) do
		print(k,v)
		if type(v) == "table" then
			dump_obj(v, with_meta_table);
		end
	end

	if with_meta_table then
		while true do
			t = getmetatable(t);
			if t == nil then print(""); break end;

			print(""); print( "~~~~~~~~~~ dump metatable ~~~~~~~~~~~");
			print(t);

			for k,v in pairs(t) do
				print(k,v)
			end
		end
	end
end

function Split(szFullString, szSeparator)  
	local nFindStartIndex = 1  
	local nSplitIndex = 1  
	local nSplitArray = {}  
	while true do  
	   local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
	   if not nFindLastIndex then  
		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
		break  
	   end  
	   nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
	   nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
	   nSplitIndex = nSplitIndex + 1  
	end  
	return nSplitArray  
end  