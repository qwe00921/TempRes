--------------------------------------------------------------
-- FileName: 	card_func.lua
-- author:		hst, 2013��9��10��
-- purpose:		��ȡ����ͼƬ
--------------------------------------------------------------

--��ȡ����ͼƬ
function GetCardPicById( cardId )
    local pic = GetPictureByAni("card."..cardId, 0);
    if pic == nil then
        pic = GetDefaultCardPic();
    end
    return pic;
end

--��ȡ���ܿ���ͼƬ
function GetSkillCardPicById( cardId )
    
end

--��ȡȱʡ�Ŀ���ͼƬ
function GetDefaultCardPic()
	return GetPictureByAni("card.card_box_db_new", 0);
end

--��ȡȱʡ�ļ��ܿ���ͼƬ
function GetDefaultSkillCardPic()
    
end