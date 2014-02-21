

equip_rein_result = {}
local p = equip_rein_result;

p.layer = nil;
p.msg = nil;

p.cardIndex = 1;
p.cardIdList = {};
p.coin = nil;
p.ui = ui_dlg_equip_rein_result;
p.preItem = nil;

--显示UI
function p.ShowUI(preItem, nowItem)
    
	p.preItem = preItem or {};
	
    if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	layer:NoMask();
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_equip_rein_result.xui", layer, nil);
	
	p.layer = layer;
	
	p.initView(preItem,nowItem);
	
end

function p.initView(preItem,nowItem)
	
	local label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_NAME);
	label:SetText(tostring(nowItem.name)); 
	label:SetVisible(false); 
	
	label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_LV_LABEL);
	label:SetVisible(false); 

	label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_LV_PRE);
	label:SetText(tostring(preItem.itemLevel)); 
	label:SetVisible(false); 
	
	--label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_LV_ARROW);
	--label:SetVisible(false); 
	
	label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_LV_NOW);
	label:SetText(tostring(nowItem.itemLevel)); 
	label:SetVisible(false); 
	
	label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_ATR_LABEL_1);
	label:SetText(GetStr("card_equip_attr"..preItem.attrType)); 
	label:SetVisible(false); 
	
	label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_ATR_PRE_1);
	label:SetText(tostring(preItem.attrValue)); 
	label:SetVisible(false); 
	
	--label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_ATR_ARROW_1);
	--label:SetVisible(false); 
	
	label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_ATR_NOW_1);
	label:SetText(tostring(nowItem.attrValue)); 
	label:SetVisible(false); 
	
	label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_ATR_LABEL_2);
	if preItem.exType1 and tonumber( preItem.exType1) ~= 0 then 
		label:SetText(GetStr("card_equip_attr"..preItem.exType1)); 
	end
	label:SetVisible(false); 
	
	label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_ATR_PRE_2);
	if preItem.exType1 and tonumber( preItem.exType1) ~= 0  then 
		label:SetText(tostring(preItem.exValue1));
	end
	label:SetVisible(false); 
	
	--label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_ATR_ARROW_2);
	--label:SetVisible(false); 
	
	label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_ATR_NOW_2);
	if preItem.exType1 and tonumber( preItem.exType1) ~= 0  then 
		label:SetText(tostring(nowItem.exValue1));
	end
	label:SetVisible(false); 
	
	
	label = GetExp(p.layer,p.ui.ID_CTRL_TEXT_ADD);
	label:SetVisible(false); 
	
	label = GetImage(p.layer,p.ui.ID_CTRL_PICTURE_BLOOD);
	label:SetVisible(false); 
	
	--当前的经验值条
	local lCardLeveInfo= SelectRowInner( T_EQUIP_LEVEL, "level", tostring(nowItem.itemLevel));
	local lCardExp = GetExp(p.layer,p.ui.ID_CTRL_TEXT_ITEM_EXP);
	lCardExp:SetVisible(false); 
	lCardExp:SetTotal(tonumber(lCardLeveInfo.exp));
	lCardExp:SetProcess(tonumber(nowItem.itemExp));
	lCardExp:SetNoText();
			
	--经验值 ID_CTRL_TEXT_EXP
	local lTextExp = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_EXP);
	lTextExp:SetVisible(false); 
	lTextExp:SetText(tostring(nowItem.itemExp).."/"..tostring(lCardLeveInfo.exp));
	
	
	local pEquipPic1 = GetImage(p.layer,p.ui.ID_CTRL_PICTURE_EQUIP);
	if tonumber(preItem.itemId) ~= 0 then
		local pEquipInfo= SelectRowInner( T_EQUIP, "id", preItem.itemId); 
		pEquipPic1:SetPicture( GetPictureByAni(pEquipInfo.item_pic,0) );
		pEquipPic1:SetVisible(false); 
	else
		pEquipPic1:SetPicture(nil);
		pEquipPic1:SetVisible(false); 
	end
	
	p.equip_rein_effect_finish();
	
	--[[
	local effectNode = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_EFFECT);
	local effectNode2 = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_EFFECT_2);
	
	
	local bt = GetButton(p.layer,p.ui.ID_CTRL_BUTTON_BACK);
    bt:SetLuaDelegate(p.OnButtonClickEvent);
	--bt:SetVisible(false);
	
	local batch = battle_show.GetNewBatch();
	local seqStar = batch:AddSerialSequence()
	local seqStar = battle_show.GetDefaultParallelSequence();
	local cmd1 = createCommandEffect():AddFgEffect( 0.5, effectNode, "skill_effect.sing_aperture_blue" );
	seqStar:AddCommand( cmd1 );
		
	local seqStar2 = batch:AddSerialSequence()
	local cmd2 = createCommandEffect():AddFgEffect( 0.5, effectNode2, "skill_effect.hurt_fire" );
	seqStar2:AddCommand( cmd2 );
	seqStar2:SetWaitBegin(cmd1)
	
	local seqStar3 = batch:AddSerialSequence()
	local cmd = createCommandLua():SetCmd( "equip_rein_effect", 1, 2, "" );
	if cmd ~= nil then
		seqStar3:AddCommand(cmd);
		seqStar3:SetWaitEnd(cmd1);
	end	
	]]--
end


function p.OnButtonClickEvent(uiNode, uiEventType, param)
	WriteCon("OnUIClickEvent....");	
	if IsClickEvent(uiEventType) then
		p.CloseUI();
	end
end

function p.equip_rein_effect_finish()
	if p.layer ~= nil then
		p.showFinal();
	end
end

function p.showFinal()
	
	local label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_NAME);
	label:SetVisible(true); 
	
	label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_LV_LABEL);
	label:SetVisible(true); 

	label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_LV_PRE);
	label:SetVisible(true); 
	
	--label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_LV_ARROW);
	--label:SetVisible(true); 
	
	label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_LV_NOW);
	label:SetVisible(true); 
	
	label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_ATR_LABEL_1);
	label:SetVisible(true); 
	
	label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_ATR_PRE_1);
	label:SetVisible(true); 
	
	--label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_ATR_ARROW_1);
	--label:SetVisible(true); 
	
	label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_ATR_NOW_1);
	label:SetVisible(true); 
	
	
	if p.preItem and p.preItem.exType1 and tonumber(p.preItem.exType1) ~= 0 then 
		label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_ATR_LABEL_2);
		label:SetVisible(true); 
		
		label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_ATR_PRE_2);
		label:SetVisible(true); 
	
		--label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_ATR_ARROW_2);
		--label:SetVisible(true); 
	
		label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_ATR_NOW_2);
		label:SetVisible(true); 
	end
	
	label = GetLabel(p.layer,p.ui.ID_CTRL_TEXT_EXP);
	label:SetVisible(true); 
	label = GetExp(p.layer,p.ui.ID_CTRL_TEXT_ADD);
	label:SetVisible(true); 
	label = GetExp(p.layer,p.ui.ID_CTRL_TEXT_ITEM_EXP);
	label:SetVisible(true); 
	label = GetImage(p.layer,p.ui.ID_CTRL_PICTURE_BLOOD);
	label:SetVisible(true); 
	
	local pEquipPic1 = GetImage(p.layer,p.ui.ID_CTRL_PICTURE_EQUIP);
	pEquipPic1:SetVisible(true); 
	
end

function p.CloseUI()
	  if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;	
		p.preItem = {};
	end
end