--------------------------------------------------------------
-- FileName: 	battle_show.lua
-- author:		zhangwq, 2013/05/16
-- purpose:		ս��������
--------------------------------------------------------------

battle_show = {}
local p = battle_show;


--��Ĭ�ϵĴ������в���Action��Ч
function p.AddActionEffect_ToSequence( duration, node, title, sequence )
	local cmd = createCommandEffect():AddActionEffect( duration, node, title );
	if cmd ~= nil then
		sequence = sequence or p.GetDefaultSerialSequence();
		sequence:AddCommand( cmd );
	end	
	return cmd;
end

--��Ĭ�ϵĲ������в���Action��Ч
function p.AddActionEffect_ToParallelSequence( duration, node, title, sequence )
	local cmd = createCommandEffect():AddActionEffect( duration, node, title );
	if cmd ~= nil then
		sequence = sequence or p.GetDefaultParallelSequence();
		sequence:AddCommand( cmd );
	end	
	return cmd;
end


--��ȡһ���µ�batch
function p.GetNewBatch()
	local battleShow = GetBattleShow();
	if battleShow == nil then
		WriteCon( "getBattleShow() failed");
		return nil;
	end
	
	local seqBatch = battleShow:AddSequenceBatch();
	if seqBatch == nil then
		WriteCon( "get new batch failed");
		return nil;
	end
	return seqBatch;
end

--ȡĬ�ϵ�����
function p.GetDefaultSequenceBatch()
	local battleShow = GetBattleShow();
	if battleShow == nil then
		WriteCon( "getBattleShow() failed");
		return nil;
	end
	
	local seqBatch = battleShow:GetDefaultSequenceBatch();
	if seqBatch == nil then
		WriteCon( "get default sequence batch() failed");
		return nil;
	end
	return seqBatch;
end


--ȡĬ�ϵĴ�����������
function p.GetDefaultSerialSequence()

	-- get battle show
	local battleShow = GetBattleShow();
	if battleShow == nil then
		WriteCon( "getBattleShow() failed");
		return nil;
	end

	-- get default serial sequence
	local sequence = battleShow:GetDefaultSequenceSerial();
	if sequence == nil then
		WriteCon( "get default sequence serial failed" );
		return nil;
	end

	return sequence;
end


--ȡĬ�ϵĲ�����������
function p.GetDefaultParallelSequence()

	-- get battle show
	local battleShow = GetBattleShow();
	if battleShow == nil then
		WriteCon( "getBattleShow() failed");
		return nil;
	end

	-- get default serial sequence
	local sequence = battleShow:GetDefaultSequenceParallel();
	if sequence == nil then
		WriteCon( "get default sequence parallel failed" );
		return nil;
	end

	return sequence;
end
