--------------------------------------------------------------
-- FileName: 	battle_show.lua
-- author:		zhangwq, 2013/05/16
-- purpose:		战斗表现秀
--------------------------------------------------------------

battle_show = {}
local p = battle_show;


--用默认的串行序列播放Action特效
function p.AddActionEffect_ToSequence( duration, node, title, sequence )
	local cmd = createCommandEffect():AddActionEffect( duration, node, title );
	if cmd ~= nil then
		sequence = sequence or p.GetDefaultSerialSequence();
		sequence:AddCommand( cmd );
	end	
	return cmd;
end

--用默认的并行序列播放Action特效
function p.AddActionEffect_ToParallelSequence( duration, node, title, sequence )
	local cmd = createCommandEffect():AddActionEffect( duration, node, title );
	if cmd ~= nil then
		sequence = sequence or p.GetDefaultParallelSequence();
		sequence:AddCommand( cmd );
	end	
	return cmd;
end


--获取一个新的batch
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

--取默认的批次
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


--取默认的串行命令序列
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


--取默认的并行命令序列
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
