--剧情后不接战斗，接界面时
--将剧情结束后的界面区分开，分别代表剧情结束后要打开的界面
after_drama_data = {}
local p = after_drama_data;
p.FIGHT = 0;	--后面接战斗，
p.CHAPTER = 10;	--后面接chapter界面
p.STAGE = 11;	--后面接stage界面