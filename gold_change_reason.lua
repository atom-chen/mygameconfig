--
-- Author: 
-- Date: 2015-10-20 17:35:26
--
local GoldChangeReasonEnum = {
	AdminControlBankGoldAdd = 1, -- 管理员修改银行金币
	AdminControlBankGoldSub = 2, -- 管理员修改银行金币
	AdminControlGoldAdd = 3,  -- 管理员修改大厅金币
	AdminControlGoldSub = 4,  -- 管理员修改大厅金币
	FromMatchSub = 5, --比赛报名
	FromMatchAdd = 6, --比赛奖励
	FromGameFreeze = 7, -- 游戏冻结
	FromGameUnfreeze = 8, -- 游戏解冻
	FromGameReUnfreeze = 9, -- 游戏新冻结
	FromAlam = 10, -- 救济金
	FromLottery = 11, -- 抽奖
	FromDaySign = 12,-- 登录奖励
	FromRedPacket = 13, -- 红包
	FromRecharge = 14,-- 银行账号充值
	FromRanking = 15, --排名奖励
	FromUserRechargeBankGoldAdd = 16, -- 用户自行充值银行增加
	FromUserRechargeBankGoldSub = 17, -- 用户自行取值银行减少
	FromUserRechargeGoldAdd = 18, -- 用户自行充值大厅金币增加
	FromUserRechargeGoldSub = 19, -- 用户自行取值大厅金币增加
	FromGameResult = 20, -- 游戏过程金币变化接口
	FromBroadcastChatSub = 21, -- 用户发起全服广播聊天扣除金币
	FromRechargeLottery = 22, -- 用户充值金币领奖
	FromFeedFortuneCat = 23, -- 用户喂养招财猫的金币奖励
	FromFeedFortuneCatConsume = 24, -- 用户喂养招财猫的金币消耗
	FromRedCoinExchange = 25, -- '红包'兑换金币
	FromWXShare = 26,--微信分享
	FromFreshmanGoldReward = 27,--新手金币奖励
	FromGuessCards = 28,--猜牌游戏

	FromItemsMatchGrands = 50, -- 比赛道具发放
	FromItemsRecharge = 51, -- 比赛道具充值
	FromItemsCancelMatch = 52, --比赛取消返回道具
	FromItemsEveryGames = 53, --隔局游戏赠送英雄币
	FromItemsMatchSignup = 54, -- 报名比赛
	FromItemsControlAdd = 55, -- 管理员增加
	FromItemsControlReduce = 56, -- 管理员减少
	FromItemsDaysign = 57, -- 每日签到道具奖励
	FromItemsDayRewards = 58, -- 领取日榜道具邮件奖励 
	FromItemsWeekRewards = 59, -- 领取周榜道具邮件奖励 
	FromItemsMatchRewards = 60, -- 领取比赛道具邮件奖励 
	FromItemsMissionRewards = 61, -- 领取mission任务奖励
	FromItemsExchangeCode = 62, -- 兑换码领取道具
	FromItemsSubExchangeCode = 63, -- 兑换码领取道具扣除
	FromItemsFeedFortuneCat = 64, -- 用户喂养招财猫的道具奖励
	FromRechargeMobiledata = 65, --用户消耗道具充值流量
	FromRechargeMobileDataFail = 66, --用户消耗道具充值流量失败返回道具消耗
	FromRoomTaskReward = 67, --房间任务奖励
	FromModiFailAdd = 68, --修改昵称失败返回改名卡
	FromItemChanceWXShare = 69,  --子用户分享任务完成
	FromItemChanceRocket = 70,  --首次王炸赢取
	FromItemChanceLottery = 71, --抽红包消耗
	FromItemChanceMatch = 72, --比赛赢取
	FromItemChance5Game = 73, -- 5胜局

	Unkown = 100,
}

return GoldChangeReasonEnum