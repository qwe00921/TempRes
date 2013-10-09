--------------------------------------------------------------
-- FileName: 	collect_mgr.lua
-- author:		xyd, 2013/08/05
-- purpose:		ͼ��������
--------------------------------------------------------------

collect_mgr = {}
local p = collect_mgr;

p.cardList = nil;
p.petCardList = nil;
p.equipCardList = nil;
p.skillCardList = nil;

p.titlePetCategory = {
	"COLLECT_PET_DRAGON",
	"COLLECT_PET_DEMON",
	"COLLECT_PET_FLY",
	"COLLECT_PET_NATURE",
	"COLLECT_PET_ANIMAL",
	"COLLECT_PET_PLANT",
	"COLLECT_PET_MATTER"
};

p.titleEquipCategory = {
	"",
	"",
	"COLLECT_EQUIP_WEAPON",
	"COLLECT_EQUIP_ARMOR",
	"COLLECT_EQUIP_ACC"
};

p.titleSkillCategory = {
	"COLLECT_SKILL_ACTIVE",
	"",
	"COLLECT_SKILL_PASSIVE"
};


-- ���ؿ�����Ϣ
function p.LoadCard( )

	WriteCon("**����ͼ������**");
	local uid = GetUID();
	if uid == 0 or uid == nil then
		return ;
	end;
	SendReq("Skill","GetSkillInfo",uid,"");
end

-- ����UI
function p.RefreshUI(dataList)

	if dataList == nil then
		WriteCon("RefreshUI():dataList is null");
		return ;
	end

	p.cardList = dataList;
	-- �������
	p.petCardList = dataList.petinfo;
	p.equipCardList = dataList.equipinfo;
	p.skillCardList = dataList.skillinfo;

	local cur_option = dlg_collect_mainui.cur_option;
	if COLLECT_OPTION_PET == cur_option then
		dlg_collect_mainui.ShowCardList(p.petCardList, cur_option, -1);
	elseif COLLECT_OPTION_EQUIP == cur_option then
		dlg_collect_mainui.ShowCardList(p.equipCardList, cur_option, -1);
	elseif COLLECT_OPTION_SKILL == cur_option then
		dlg_collect_mainui.ShowCardList(p.skillCardList, cur_option, -1);
	end

end

--���ش���࿨Ƭ
function p.LoadCardByCategory( category )

	if category == nil then
		WriteCon("loadCardByCategory():category is null");
		return ;
	end
	
	if COLLECT_OPTION_PET == category then
		dlg_collect_mainui.ShowCardList(p.petCardList, category, -1);
	elseif COLLECT_OPTION_EQUIP == category then
		dlg_collect_mainui.ShowCardList(p.equipCardList, category, -1);
	elseif COLLECT_OPTION_SKILL == category then
		dlg_collect_mainui.ShowCardList(p.skillCardList, category, -1);
	end
end

--�����ӷ��࿨Ƭ
function p.LoadCardByChildCategory( category,childCategory )

	if category == nil then
		WriteCon("LoadCardByChildCategory():category is null");
		return ;
	end
	
	if COLLECT_OPTION_PET == category then
		dlg_collect_mainui.ShowCardList(p.LoadCardByPetCategory(childCategory), category, childCategory);
	elseif COLLECT_OPTION_EQUIP == category then
		dlg_collect_mainui.ShowCardList(p.LoadCardByEquipCategory(childCategory), category, childCategory);
	elseif COLLECT_OPTION_SKILL == category then
		dlg_collect_mainui.ShowCardList(p.LoadCardBySkillCategory(childCategory), category, childCategory);
	end
end

--���س���ͼ������
function p.LoadCardByPetCategory( category )
	
	if p.petCardList == nil or #p.petCardList <= 0 then
		WriteCon("LoadCardByPetCategory():cardList is null");
		return nil;
	end
	
	local t = {};
	for k,v in ipairs(p.petCardList) do
		if tonumber(v.pierce) == category then
			t[#t+1] = v;
		end
	end
	return t;
end

--����װ��ͼ������
function p.LoadCardByEquipCategory( category )
	
	if p.equipCardList == nil or #p.equipCardList <= 0 then
		WriteCon("LoadCardByEquipCategory():cardList is null");
		return nil;
	end
	
	local t = {};
	for k,v in ipairs(p.equipCardList) do
		if tonumber(v.type) == category then
			t[#t+1] = v;
		end
	end
	return t;
end

--���ؽ�ɫ����ͼ������
function p.LoadCardBySkillCategory( category )
	
	if p.skillCardList == nil or #p.skillCardList <= 0 then
		WriteCon("LoadCardBySkillCategory():cardList is null");
		return nil;
	end
	
	local t = {};
	for k,v in ipairs(p.skillCardList) do
		if tonumber(v.type) == category then
			t[#t+1] = v;
		end
	end
	return t;
end

--��ȡ����
function p.GetTitleInfo(category,childCategory)

	local title = nil;
	if COLLECT_OPTION_PET == category then
			title = GetStr(p.titlePetCategory[childCategory]);
	elseif COLLECT_OPTION_EQUIP == category then
			title = GetStr(p.titleEquipCategory[childCategory]);
	elseif COLLECT_OPTION_SKILL == category then
			title = GetStr(p.titleSkillCategory[childCategory]);
	end
	return title;
end

--��ȡ��Ƭ��������
function p.GetCardMaxNum(category,childCategory)
	
	local num = 0;
	if category == COLLECT_OPTION_PET and childCategory == COLLECT_PET_DRAGON then
		--��
		num = COLLECT_NUM_DRAGON;
	elseif category == COLLECT_OPTION_PET and childCategory == COLLECT_PET_DEMON then
		--��ħ
		num = COLLECT_NUM_DEMON;
	elseif category == COLLECT_OPTION_PET and childCategory == COLLECT_PET_FLY then
		--����
		num = COLLECT_NUM_FLY;
	elseif category == COLLECT_OPTION_PET and childCategory == COLLECT_PET_NATURE then
		--��Ȼ
		num = COLLECT_NUM_NATURE;
	elseif category == COLLECT_OPTION_PET and childCategory == COLLECT_PET_ANIMAL then
		--����
		num = COLLECT_NUM_ANIMAL;
	elseif category == COLLECT_OPTION_PET and childCategory == COLLECT_PET_PLANT then
		--ֲ��
		num = COLLECT_NUM_PLANT;
	elseif category == COLLECT_OPTION_PET and childCategory == COLLECT_PET_MATTER then
		--����
		num = COLLECT_NUM_MATTER;
	elseif category == COLLECT_OPTION_EQUIP and childCategory == COLLECT_EQUIP_WEAPON then
		--����
		num = COLLECT_NUM_WEAPON;
	elseif category == COLLECT_OPTION_EQUIP and childCategory == COLLECT_EQUIP_ARMOR then
		--����
		num = COLLECT_NUM_ARMOR;
	elseif category == COLLECT_OPTION_EQUIP and childCategory == COLLECT_EQUIP_ACC then
		--��Ʒ
		num = COLLECT_NUM_ACC;
	elseif category == COLLECT_OPTION_SKILL and childCategory == COLLECT_SKILL_ACTIVE then
		--��������
		num = COLLECT_NUM_ACTIVE;
	elseif category == COLLECT_OPTION_SKILL and childCategory == COLLECT_SKILL_PASSIVE then
		--��������
		num = COLLECT_NUM_PASSIVE;
	elseif category == COLLECT_OPTION_PET and childCategory == -1 then
		--����ͼ��
		num = COLLECT_NUM_PET;
	elseif category == COLLECT_OPTION_EQUIP and childCategory == -1 then
		--װ��ͼ��
		num = COLLECT_NUM_EQUIP;
	elseif category == COLLECT_OPTION_SKILL and childCategory == -1 then
		--��ɫ����ͼ��
		num = COLLECT_NUM_SKILL;
	end
	return num;
end

-- ͨ��cardID��ȡ������Ϣ
function p.GetCardById( cardId )
	if cardId == nil then
		return nil;
	end
	for i=1, #p.cardList do
		local card = p.cardList[i];
		if tonumber( card.id ) == cardId then
			return card;
		end
	end
end



-- ��ȡ���ܿ���ͼƬ
function p.GetCardPicture(skill_id)
	--WriteCon("skill_id = "..skill_id);
	--local skill_id = SelectCell( T_SKILL, skill_id, "picPath" )
	--return GetPictureByAni("card.card_box_db", 0);
	local pic = GetPictureByAni("card.skill_"..skill_id, 0);
	if pic == nil then
		pic = GetPictureByAni("card.card_box_db_new", 0);
	end
	return pic;
end


--�������
function p.ClearData()
	p.cardList = nil;
	p.petCardList = nil;
	p.equipCardList = nil;
	p.skillCardList = nil;
end