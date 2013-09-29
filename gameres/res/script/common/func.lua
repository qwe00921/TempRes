--------------------------------------------------------------
-- FileName: 	func.lua
-- author:		
-- purpose:		常用函数
--------------------------------------------------------------

math.randomseed(os.time());

function LogInfo(fmt, ...)
    LuaLogInfo(string.format(fmt, unpack(arg)));
end

function LogError(fmt, ...)
    LuaLogError(string.format(fmt, unpack(arg)));
end

function SafeS2N(str)
	if nil == str or type(str) ~= "string" then
		return 0;
	end
	local n = tonumber(str);
	if nil == n then
		return 0;
	end
	return n;
end

function SafeN2S(n)
	if nil == n or type(n) ~= "number" then
		return "";
	end
	local str = tostring(n);
	if nil == str then
		return "";
	end
	return str;
end

function ConvertN(n)
	if nil == n or type(n) ~= "number" then
		return 0;
	end
	return n;
end

function ConvertS(s)
	if nil == s or type(s) ~= "string" then
		return "";
	end
	return s;
end

function CheckN(n)
	if nil == n or type(n) ~= "number" then
		return false;
	end
	return true;
end

function CheckS(s)
	if nil == s or type(s) ~= "string" then
		return false;
	end
	return true;
end

function CheckT(t)
	if nil == t or type(t) ~= "table" then
		return false;
	end
	return true;
end

function CheckB(b)
	if nil == b or type(b) ~= "boolean" then
		return false;
	end
	return true;
end

function CheckFunc(func)
	if nil == func or type(func) ~= "function" then
		return false;
	end
	return true;
end

function CheckP(pointer)
	if nil == pointer or type(pointer) ~= "userdata" then
		return false;
	end
	return true;
end

function CheckStruct(struct)
	if nil == struct or type(struct) ~= "userdata" then
		return false;
	end
	return true;
end

function MakeTagList(...)
	local taglist	= {};
	for i, v in ipairs(arg) do
		if CheckN(v) then
			table.insert(taglist, v);
		end
	end
	return taglist;
end

--浮点数比较
function floatEqual(a, b)
	if not CheckN(a) or
		not CheckN(b) then
		return false;
	end
	
	if math.abs(a - b) < 0.0001 then
		return true;
	end
	
	return false;
end

--获取数字的整数位
function getIntPart(x)
	if not CheckN(x) then
		return 0;
	end
	if x <= 0 then
	   return math.ceil(x);
	end
	local n	= math.ceil(x);
	if floatEqual(n, x) then
	   x = n;
	else
	   x = n - 1;
	end
	return x;
end

--返回数字并保留小数点后N位
function GetNumDot(nNumber, nDotNum)
	if not CheckN(nNumber) or
		not CheckN(nDotNum) or 
		nDotNum <= 0 then
		return 0;
	end
	local nRes	= nNumber * (10^nDotNum);
	return getIntPart(nRes) / (10^nDotNum);
end

--将秒数转化为格式化时间，用于显示倒计时,flag=0表示为mm:ss格式，flag＝1表示为hh:mm:ss格式
function FormatTime(second,flag)
	local result="";
	
	if flag==1 then
		local hour=getIntPart(second/3600);
		if hour < 10 then
			result=result.."0"..SafeN2S(hour)..":";
		else
			result=result..SafeN2S(hour)..":";
		end
	end
	
	local mi=getIntPart((second%3600)/60);
	if mi < 10 then
		result=result.."0"..SafeN2S(mi)..":";
	else
		result=result..SafeN2S(mi)..":";
	end
	
	local se = second%60;
	if se < 10 then
		result=result.."0"..SafeN2S(se);
	else
		result=result..SafeN2S(se);
	end
	
	return result;
end

--将秒数转化为格式化为中文时间
function FormatChineseTime(second)
	local result="";
	
	if second>=3600 then
		local hour=getIntPart(second/3600);
		result=result..SafeN2S(hour)..GetTxtPub("hours");
	end
	
	if second>= 60 then
		local mi=getIntPart((second%3600)/60);
		result=result..SafeN2S(mi)..GetTxtPub("minute");
	end
	
	local se = second%60;
	result=result..SafeN2S(se)..GetTxtPub("second");
	
	return result;
end

--获取数字的个位
function Num1(n)
	return n % 10;
end

function Num2(n)
	return getIntPart(Num1(n / 10));
end

function Num3(n)
	return Num1(getIntPart(n / 100));
end

function Num4(n)
	return Num1(getIntPart(n / 1000));
end

function Num5(n)
	return Num1(getIntPart(n / 10000));
end

function Num6(n)
	return Num1(getIntPart(n / 100000));
end

function Num7(n)
	return Num1(getIntPart(n / 1000000));
end

function Num8(n)
	return Num1(getIntPart(n / 10000000));
end

function Num9(n)
	return Num1(getIntPart(n / 100000000));
end

-- 只打印数字与字符串
function LogInfoT(t)
	if not CheckT(t) then
		return;
	end
	
	for	i, v in ipairs(t) do
		if type(v) == "number" then
			LogInfo("[%d][%d]", i, v);
		elseif type(v) == "string" then 
			LogInfo("[%d][%s]", i, v);
		end
	end
end


function GetCurrentTime()
	return os.time()
end

function FomatBigNumber(value)
	if value<10000 then
		return SafeN2S(value);
	elseif value<100000000 then
		local v1=getIntPart(value/10000);
		return SafeN2S(v1)..GetTxtPub("ten");
	else 
		local v1=getIntPart(value/100000000);
		return SafeN2S(v1)..GetTxtPub("hm");
	end
end


--金钱格式化
function MoneyFormat(nMoney)
    if(nMoney == nil) then
        LogInfo("MoneyFormat not num!");
        return "";
    end
    if(nMoney>=10000) then
        nMoney = math.floor(nMoney/10000)..GetTxtPub("ten");
    end
    return nMoney.."";
end
