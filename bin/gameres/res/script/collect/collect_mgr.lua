--------------------------------------------------------------
-- FileName: 	collect_mgr.lua
-- author:		xyd, 2013/08/05
-- purpose:		图鉴管理器
--------------------------------------------------------------

collect_mgr = {}
local p = collect_mgr;

p.cardList = nil;
p.petCardList = nil;
p.equipCardList = nil;
p.skillCardList = nil;

p.petBaseCardList = nil;
p.equipBaseCardList = nil;
p.skillBaseCardList = nil;

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


-- 加载卡牌信息
function p.LoadCard( )

	WriteCon("**请求图鉴数据**");
	local uid = GetUID();
	if uid == 0 or uid == nil then
		return ;
	end;
	SendReq("Collection","GetCollectionInfo",uid,"");
end

-- 加载UI
function p.RefreshUI(dataList)

	if dataList == nil then
		WriteCon("RefreshUI():dataList is null");
		return ;
	end

	p.cardList = dataList;
	-- 拆分数据
	p.petCardList = dataList.cards;
	p.equipCardList = dataList.items;
	p.skillCardList = dataList.skills;
	
	local cur_option = dlg_collect_mainui.cur_option;
	
	if COLLECT_OPTION_PET == cur_option then
		dlg_collect_mainui.ShowPage(p.petCardList);
	elseif COLLECT_OPTION_EQUIP == cur_option then
		dlg_collect_mainui.ShowPage(p.equipCardList);
	elseif COLLECT_OPTION_SKILL == cur_option then
		dlg_collect_mainui.ShowPage(p.skillCardList);
	end

end

-------------------------------------server data-------------------------

--加载大分类卡片
function p.LoadCardByCategory( category )

	dlg_collect_mainui.cur_option = category;
	dlg_collect_mainui.cur_category = -1;
	dlg_collect_mainui.cur_rare = nil;
	dlg_collect_mainui.cur_page = 1;
	
	if COLLECT_OPTION_PET == category then
		dlg_collect_mainui.ShowPage(p.petCardList);
	elseif COLLECT_OPTION_EQUIP == category then
		dlg_collect_mainui.ShowPage(p.equipCardList);
	elseif COLLECT_OPTION_SKILL == category then
		dlg_collect_mainui.ShowPage(p.skillCardList);
	end
	
end

--加载子分类卡片
function p.LoadCardByChildCategory( category,childCategory )

	dlg_collect_mainui.cur_option = category;
	dlg_collect_mainui.cur_category = childCategory;
	dlg_collect_mainui.cur_rare = nil;
	dlg_collect_mainui.cur_page = 1;
	
	local cardList = nil;
	local tableName = nil;
	if COLLECT_OPTION_PET == category then
		cardList = p.petCardList;
		tableName = T_CARD;
	elseif COLLECT_OPTION_EQUIP == category then
		cardList = p.equipCardList;
		tableName = T_ITEM;
	elseif COLLECT_OPTION_SKILL == category then
		cardList = p.skillCardList;
		tableName = T_SKILL;
	end

	if cardList == nil or #cardList <= 0 then
		WriteCon("LoadCardByChildCategory():cardList is null");
		return nil;
	end
	
	local t = {};
	for k,v in ipairs(cardList) do
		local cardItem = SelectRow(tableName,v.id);
		if COLLECT_OPTION_PET == category then
			if tonumber(cardItem.pierce) == tonumber(childCategory)  then
				t[#t+1] = v;
			end
		elseif COLLECT_OPTION_EQUIP == category then
			if tonumber(cardItem.type) == tonumber(childCategory)  then
				t[#t+1] = v;
			end
		elseif COLLECT_OPTION_SKILL == category then
			if tonumber(cardItem.type) == tonumber(childCategory)  then
				t[#t+1] = v;
			end
		end
	end
	
	dlg_collect_mainui.ShowPage(t);
end

------------------------base data----------------------------------------

--初始化基础图鉴卡牌信息
function p.InitBaseCardList()
	p.petBaseCardList = SelectRowList(T_CARD);
	p.equipBaseCardList = SelectRowList(T_ITEM);
	p.skillBaseCardList = SelectRowList(T_SKILL);
end

--获取基础卡牌列表
function p.GetBaseCardList( category,childCategory)

	dlg_collect_mainui.cur_option = category;
	dlg_collect_mainui.cur_category = childCategory;
	dlg_collect_mainui.cur_rare = nil;
	
	local cardList = nil;
	if COLLECT_OPTION_PET == category then
		cardList = p.petBaseCardList;
	elseif COLLECT_OPTION_EQUIP == category then
		cardList = p.equipBaseCardList;
	elseif COLLECT_OPTION_SKILL == category then
		cardList = p.skillBaseCardList;
	end

	if cardList == nil or #cardList <= 0 then
		WriteCon("GetBaseCardList():cardList is null");
		return nil;
	end
	
	if childCategory == -1 then
		return cardList;
	end
	
	local t = {};
	for k,v in ipairs(cardList) do
		if COLLECT_OPTION_PET == category then
			if tonumber(v.pierce) == tonumber(childCategory)  then
				t[#t+1] = v;
			end
		elseif COLLECT_OPTION_EQUIP == category then
			if tonumber(v.type) == tonumber(childCategory)  then
				t[#t+1] = v;
			end
		elseif COLLECT_OPTION_SKILL == category then
			if tonumber(v.type) == tonumber(childCategory)  then
				t[#t+1] = v;
			end
		end
	end
	return t;
end

------------------------------------star----------------------------

--加载星级卡牌
function p.LoadCardByStar(rare)
	
	dlg_collect_mainui.cur_rare = rare;
	local category = dlg_collect_mainui.cur_option;
	local childCategory = dlg_collect_mainui.cur_category;
	dlg_collect_mainui.cur_page = 1;
	
	local cardList = nil;
	local tableName = nil;
	if COLLECT_OPTION_PET == category then
		cardList = p.petCardList;
		tableName = T_CARD;
	elseif COLLECT_OPTION_EQUIP == category then
		cardList = p.equipCardList;
		tableName = T_ITEM;
	elseif COLLECT_OPTION_SKILL == category then
		cardList = p.skillCardList;
		tableName = T_SKILL;
	end

	if cardList == nil or #cardList <= 0 then
		WriteCon("LoadCardByStar():cardList is null");
		return nil;
	end
	
	local t = {};
	for k,v in ipairs(cardList) do
		local cardItem = SelectRow(tableName,v.id);
		if childCategory == -1 then
			if tonumber(cardItem.rare) == tonumber(rare)  then
				t[#t+1] = v;
			end
		else
			if COLLECT_OPTION_PET == category then
				if (tonumber(cardItem.pierce) == tonumber(childCategory)) and (tonumber(cardItem.rare) == tonumber(rare))  then
					t[#t+1] = v;
				end
			elseif COLLECT_OPTION_EQUIP == category then
				if (tonumber(cardItem.type) == tonumber(childCategory)) and (tonumber(cardItem.rare) == tonumber(rare))  then
					t[#t+1] = v;
				end
			elseif COLLECT_OPTION_SKILL == category then
				if (tonumber(cardItem.type) == tonumber(childCategory)) and (tonumber(cardItem.rare) == tonumber(rare))  then
					t[#t+1] = v;
				end
			end
		end
	end
	dlg_collect_mainui.ShowPage(t);
end

--加载基础星级卡牌
function p.GetBaseRareCardList(rare)

	local category = dlg_collect_mainui.cur_option;
	local childCategory = dlg_collect_mainui.cur_category;
	
	local cardList = nil;
	if COLLECT_OPTION_PET == category then
		cardList = p.petBaseCardList;
	elseif COLLECT_OPTION_EQUIP == category then
		cardList = p.equipBaseCardList;
	elseif COLLECT_OPTION_SKILL == category then
		cardList = p.skillBaseCardList;
	end

	if cardList == nil or #cardList <= 0 then
		WriteCon("GetBaseRareCardList():cardList is null");
		return nil;
	end
	
	local t = {};
	for k,v in ipairs(cardList) do
		if childCategory == -1 then
			if tonumber(v.rare) == tonumber(rare)  then
				t[#t+1] = v;
			end
		else
			if COLLECT_OPTION_PET == category then
				if (tonumber(v.pierce) == tonumber(childCategory)) and (tonumber(v.rare) == tonumber(rare))  then
					t[#t+1] = v;
				end
			elseif COLLECT_OPTION_EQUIP == category then
				if (tonumber(v.type) == tonumber(childCategory)) and (tonumber(v.rare) == tonumber(rare))  then
					t[#t+1] = v;
				end
			elseif COLLECT_OPTION_SKILL == category then
				if (tonumber(v.type) == tonumber(childCategory)) and (tonumber(v.rare) == tonumber(rare))  then
					t[#t+1] = v;
				end
			end
		end
	end
	return t;
end

------------------------------------common----------------------------

--获取标题
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

-- 通过cardID获取卡牌信息
function p.GetCardById( cardId, category)

	local list=nil;
	if COLLECT_OPTION_PET == category then
		list = p.petBaseCardList;
	elseif COLLECT_OPTION_EQUIP == category then
		list = p.equipBaseCardList;
	elseif COLLECT_OPTION_SKILL == category then
		list = p.skillBaseCardList;
	end
	
	for i=1,#list do
		local card = list[i];
		if tonumber( card.id ) == cardId then
			return card;
		end
	end
end

--检查卡片是否收集
function p.checkCardIsCollect(cardId,cardList)

	for i=1,#cardList do
		if (tonumber(cardId) == tonumber(cardList[i].id)) then
            return true;
        end
	end
	return false;
end


-- 获取技能卡牌图片
function p.GetCardPicture(id,category)

	local pic = nil;
	if COLLECT_OPTION_PET == category then
		pic = GetPictureByAni("card."..id, 0);
	elseif COLLECT_OPTION_EQUIP == category then
		pic = GetPictureByAni("item.item_temp", 0);
	elseif COLLECT_OPTION_SKILL == category then
		pic = GetPictureByAni("card.skill_"..id, 0);
	end
	
	if pic == nil then
		pic = GetPictureByAni("card.card_box_db_new", 0);
	end
	return pic;
end

-- 获取分页卡牌列表
function p.GetCardListByPage(cardList,startIndex,endIndex)

	local t = {};
	for i=startIndex,endIndex do
		t[#t+1] = cardList[i];
	end
	return t;
end



--清空数据
function p.ClearData()
	p.cardList = nil;
	p.petCardList = nil;
	p.equipCardList = nil;
	p.skillCardList = nil;
	p.petBaseCardList = nil;
	p.equipBaseCardList = nil;
	p.skillBaseCardList = nil;
end