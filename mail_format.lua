local conf = {}

conf.match_format = {
	title = "比赛奖励",
	content = "恭喜您在name中获得第rank名。",
	from = "管理员"
}

conf.match_cancel_format = {
	title = "比赛取消通知",
	content = "您报名的name，由于人数不足，赛事取消。",
	from = "管理员" --不填则为 htgames
}

conf.system_bonus = {
		title = "系统奖励",
		content = "首充奖励",
		from = "管理员" --不填则为 htgames
}

conf.buy_match_qualif = {
		title = "系统提示",
		content = "恭喜您获得本次公开赛参赛资格，请准时参加，角逐百万现金大奖！",
		from = "管理员" --不填则为 htgames
}

conf.red_coin_lottery = {
		title = "奖券夺宝",
		content = "恭喜你获得%d期奖券夺宝%s奖励!",
		from = "管理员" --不填则为 htgames
}

conf.red_coin_lottery_cancel = {
		title = "奖券夺宝取消",
		content = "由于参与人数不足第%d期奖券夺宝未开奖，奖券已全部归还。",
		from = "管理员" --不填则为 htgames
}

conf.friends_gift = {
	title = "%s给您赠送了%s",
	content = "关心不需要理由，赠送的%s，是我对你持久不变的情谊~",
	from = "%s"
}

conf.friends_refuse = {
	title = "%s拒绝了你的好友请求",
	content = "xxx拒绝了您的好友请求，赠礼将转化为金豆返还给您。",
	from = "管理员"
}

return conf
