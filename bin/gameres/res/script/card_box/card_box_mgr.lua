--------------------------------------------------------------
-- FileName: 	card_box_mgr.lua
-- author:		hst, 2013/07/10
-- purpose:		���������--������ؿ�������
--------------------------------------------------------------

card_box_mgr = {}
local p = card_box_mgr;
p.cardList = nil;
p.layer = nil;
p.intent = nil;
p.selectCard = nil;
p.selectCardList = {};
p.bag_max = nil;

----------------�����б�Ĺ���-----------------------

--���б�������ָ���Ŀ���
p.delCardId = nil;

--��¼�ںϿ��Ƶ��Ǽ������ںϹ���ʹ��
p.fuseCardRare = nil;

--������װ���Ŀ���
p.isEquiped = false;

--���б������ζ����������
p.isDelLeader = false;

--���б������β��ɱ�ѡ��Ϊ�����ĸ�����,��Ҫָ��"card_mate"��ֵ��
p.isSelectEvolution = false;
p.cardMate = nil;

--��ѡ�������������ѡ��Ч��
p.selectMaxNum = nil;
p.selectMaxNumMsg = nil;

p.titleText = nil;
p.tipText = nil;

--�����еĿ��Ʋ��ܷ���ֿ�
p.isNoSelectInTeam = false;
p.noSelectInTeamMsg = nil;

--ѡ�������Ŀ���
p.isSelectMaxLevel = false;

--�����û����еĿ�����Ϣ
function p.LoadAllCard()
    p.layer = dlg_card_box_mainui.layer;
    p.intent = dlg_card_box_mainui.intent;
    --WriteCon("**���󿨰�����**");
    local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
    SendReq("User","GetUserCardsInfo",uid,"");
end

--����ص�����ʾ�����б�
function p.RefreshUI( data )
    if data == nil then
        WriteCon("RefreshUI():dataList is null");
        return ;
    end
    local dataList = data.user_cards;
    p.bag_max = data.bag_max ;
    p.cardList = {};

    if p.intent == CARD_INTENT_INTENSIFY then
        p.cardList = p.LoadIntensifyCard( dataList );

    elseif p.intent == CARD_INTENT_EVOLUTION then
        p.cardList = p.LoadEvolutionCard( dataList );

    elseif p.intent == CARD_INTENT_GETLIST or p.intent == CARD_INTENT_GETONE then
        p.cardList = p.LoadSelectCardList( dataList );
        
    else
        p.cardList = dataList;
    end
 
    if p.cardList ~= nil and #p.cardList > 0 then
        dlg_card_box_mainui.ShowCardList( p.cardList );
    end
    
    dlg_card_box_mainui.UpdateDepotInfo();
end

--���ؿ�ǿ���Ŀ���
function p.LoadIntensifyCard( cardList )
    if cardList =="" or cardList == nil then
        return nil;
    end
    local t = {};
    for k, v in ipairs(cardList) do
        if p.IsMaxLevel( v ) == false then
            t[#t+1] = v;
        end
    end
    return t;
end

--���������Ŀ���
function p.LoadMaxLevelCard( cardList )
    if cardList =="" or cardList == nil then
        return nil;
    end
    local t = {};
    for k, v in ipairs(cardList) do
        if p.IsMaxLevel( v ) == true then
            t[#t+1] = v;
        end
    end
    return t;
end

--���ؿɽ����Ŀ���
function p.LoadEvolutionCard( cardList )
    if cardList =="" or cardList == nil then
        return nil;
    end
    local t = {};
    local tempCardList = cardList;
    for i=1, #tempCardList do
        local card = tempCardList[i];
        local cardMaxRare = SelectCell( T_CARD, card.card_id, "evolution_max" );
        if cardMaxRare ~= card.rare then
            local theSameCard = 0;
            local cardMate = SelectCell( T_CARD, card.card_id, "card_mate" );
            for k, v in ipairs(cardList) do
                local cardMate2 = SelectCell( T_CARD, v.card_id, "card_mate" );
                if cardMate == cardMate2 then
                    if theSameCard >= 2 then
                        break ;
                    end
                    local cardMaxRare2 = SelectCell( T_CARD, v.card_id, "evolution_max" );
                    if cardMaxRare2 ~= v.rare then
                        theSameCard = theSameCard + 1;
                    end
                end
            end
            if theSameCard >= 2 then
                t[#t+1] = card;
            end
        end
    end
    return t;
end

--���ؿɱ�ѡ��Ŀ���
function p.LoadSelectCardList ( cardList )
    if cardList =="" or cardList == nil then
        return nil;
    end
    --����ָ������
    if p.delCardId ~= nil then
        for k, v in ipairs(cardList) do
            if tonumber( v.id ) == p.delCardId then
                table.remove( cardList, k);
                break ;
            end
        end
    end

    --���ζ����е�������
    if p.isDelLeader then
        cardList = p.LoadUnLeaderCard( cardList );
    end

    --���β��ɱ�ָ��Ϊ�����ĸ�����
    if p.isSelectEvolution and p.cardMate ~= nil then
        cardList = p.LoadSelectEvolutionCard ( cardList,p.cardMate );
    end
    
    --ֻ���������Ŀ���
    if p.isSelectMaxLevel == true then
        cardList = p.LoadMaxLevelCard ( cardList );
    end
	
	--���γ����ں������Ǽ���Χ�Ŀ���
	if p.fuseCardRare ~= nil then
		cardList = p.LoadCanFuseCard(cardList);		
	end
	
	if p.isEquiped then
		cardList = p.LoadNoEquipCard(cardList);
	end
    
    return cardList;
end

--����û��װ���Ŀ���
function p.LoadNoEquipCard(cardList)
	local t = {};	
	for k, v in ipairs(cardList) do
		if tonumber( v.armor ) == 0 and tonumber( v.jewelry ) == 0 and tonumber( v.weapon ) == 0 then
			t[#t+1] = v;
		end			
	end
	return t;
end
	
--��������ںϵĿ���
function p.LoadCanFuseCard(cardList)
	
	local maxRare = p.fuseCardRare + 2;
	local minRare = p.fuseCardRare - 2;
	if minRare < 1 then minRare = 1 end
	if maxRare > 5 then maxRare = 5 end

	local t = {};	
	for k, v in ipairs(cardList) do
		if tonumber( v.rare ) <= maxRare and tonumber( v.rare ) >= minRare then
			t[#t+1] = v;	
		end	
	end
	return t;
end

--����������
function p.LoadUnLeaderCard( cardList )
    if cardList =="" or cardList == nil then
        return nil;
    end
    
    local t = {};
    for k, v in ipairs(cardList) do
        if not v.leader_check then
            t[#t+1] = v;
        end
    end
    return t;
end

--����ͬһ���Ŀ������ṩ����
function p.LoadSelectEvolutionCard ( cardList,cardMate )
    if cardList =="" or cardList == nil then
        return nil;
    end
    local t = {};
    for k, v in ipairs(cardList) do
        local cardMate2 = SelectCell( T_CARD, v.card_id, "card_mate" );
        if cardMate == cardMate2 then
            t[#t+1] = v;
        end
    end
    return t;
end

--�Ƿ�����
function p.IsMaxLevel( card )
    local level = tonumber( card.level );
    local maxLevel = SelectCell( T_CARD, card.card_id, "max_level" );
    
    if tonumber( maxLevel ) == level then
        return true;
    else
        return false;    
    end 
end

--��ʾ���п���
function p.ShowAllCards()
    dlg_card_box_mainui.ShowCardList( p.cardList );
end

--����ĳһ����Ŀ���
function p.LoadCardByCategory( category )
    if category == nil then
        --WriteCon("loadCardByCategory():category is null");
        return ;
    end
    local cardList = p.GetCardList( category );
    dlg_card_box_mainui.ShowCardList( cardList );
end

--���ȼ�����
function p.SortByLevelDes()
	table.sort(p.cardList, p.sortLevelDes);
	p.ShowAllCards();
end

--���Ǽ�����
function p.SortByRareDes()
    table.sort(p.cardList, p.sortRareDes);
    p.ShowAllCards();
end

--��ȡĳһ���࿨��
function p.GetCardList( category )
    if p.cardList == nil or #p.cardList <= 0 then
        return nil;
    end
    local t = {};
    for k,v in ipairs(p.cardList) do
        if tonumber(v.pierce) == category then
            t[#t+1] = v;
        end
    end
    return t;
end

function p.ClearSelectList()
    for k, v in ipairs(p.selectCardList) do
        v:DelAniEffect("ui.card_select_fx");
    end
    p.selectCardList={};
end

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

--ɾ���б��е�ĳ�ſ��ƣ��������α�ѡ��
function p.SetDelCardById(cardId)
    if cardId == nil then
        return;
    end
    p.delCardId = tonumber( cardId );
end

--���б������β��ɱ�ѡ��Ϊ�����ĸ�����
function p.SetSelectEvolution( cardMate, bEnable )
    if bEnable == nil or cardMate == nil then
        return;
    end
    p.cardMate = cardMate;
    p.isSelectEvolution = bEnable;
end

--��������������
function p.SetDelLeader( bEnable )
    if bEnable == nil then
        return;
    end
    p.isDelLeader = bEnable;
end

--��ȡ��ѡ��Ŀ���
function p.GetSelectCard()
    return p.GetCardById( p.selectCard:GetId() );
end

--��ȡ��ѡ��Ŀ����б�
function p.GetSelectCardList()
    local t = {};
    for k, v in ipairs(p.selectCardList) do
        t[#t+1] = p.GetCardById( v:GetId() );
    end
    return t;
end

function p.SetSelectMaxNum( num )
	if num ~= nil then
		p.selectMaxNum = tonumber( num );
	end 
end

function p.SetSelectMaxNumMsg( str )
    if str ~= nil then
        p.selectMaxNumMsg = tostring( str );
    end 
end

function p.SetTitleText( str )
	if str ~= nil then
		p.titleText = tostring( str );
	end
end

function p.SetTipText( str )
    if str ~= nil then
        p.tipText = tostring( str );
    end
end

function p.SetNoSelectInTeam( bEnable )
	if bEnable ~= nil then
		p.isNoSelectInTeam = bEnable;
	end
end

function p.SetNoSelectInTeamMsg( str )
    if str ~= nil then
        p.noSelectInTeamMsg = str;
    end
end

function p.SetEquiped( bEnable )
	if bEnable ~= nil then
		p.isEquiped = bEnable;
	end
end

--����ֻ��ʾ�����Ŀ���
function p.SetSelectMaxLevel( bEnable )
    if bEnable ~= nil then
        p.isSelectMaxLevel = bEnable;
    end
end

--�����ںϿ��Ƶ��Ǽ�
function p.SetFuseCardRare( num )
	if num ~= nil then
		p.fuseCardRare = tonumber( num );
	end 
end

-- �ȼ�����
function p.sortLevelDes(a,b)
    if tonumber(a.level) == tonumber(b.level) then
        return tonumber(a.id) < tonumber(b.id);
    else
        return tonumber(a.level) < tonumber(b.level);
    end
end

-- ϡ�ж�����
function p.sortRareDes(a,b)
    if tonumber(a.rare) == tonumber(b.rare) then
        return tonumber(a.id) < tonumber(b.id);
    else
        return tonumber(a.rare) < tonumber(b.rare);
    end
end


--�������
function p.ClearData()
    p.cardList = nil;
    p.layer = nil;
    p.intent = nil;
    p.selectCard = nil;
    p.selectCardList = {};
    p.delCardId = nil;
    p.isDelLeader = false;
    p.isDelUnEvolution = false;
    p.isSelectEvolution = false;
    p.cardMate = nil;
    p.selectMaxNum = nil;
    p.selectMaxNumMsg = nil;
    p.titleText = nil;
    p.tipText = nil;
    p.isNoSelectInTeam = false;
    p.noSelectInTeamMsg = nil;
    p.bag_max = nil;
    p.isSelectMaxLevel = false;
	p.fuseCardRare = nil;
	p.isEquiped = false;
end