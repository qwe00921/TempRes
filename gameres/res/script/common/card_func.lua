--------------------------------------------------------------
-- FileName: 	card_func.lua
-- author:		hst, 2013年9月10日
-- purpose:		获取卡牌图片
--------------------------------------------------------------

--获取卡牌图片
function GetCardPicById( cardId )
    local pic = GetPictureByAni("card."..cardId, 0);
    if pic == nil then
        pic = GetDefaultCardPic();
    end
    return pic;
end

--获取技能卡牌图片
function GetSkillCardPicById( cardId )
    
end

--获取缺省的卡牌图片
function GetDefaultCardPic()
	return GetPictureByAni("card.card_box_db_new", 0);
end

--获取缺省的技能卡牌图片
function GetDefaultSkillCardPic()
    
end