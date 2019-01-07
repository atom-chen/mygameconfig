ROOMCONFIG = {
 {
  rooms = {
   [2]={
    changeTableThresholdUp = 20,
    rankScore = 50,
    gameType = "zjh",
    roomID = 4002,
    maxCRobotCnt = 5,
    baseScore = 100,
    minPlayer = 2,
    minScore = 10000,
    leaveThresholdUp = 150,
    maxrobot = 17,
    maxOdds = 99999,
    compareHand = 2,
    escapeScore = 0,
    maxHand = 10,
    maxScore = 200000,
    roomType = 1,
    leaveThresholdDown = 50,
    maxPlayer = 6,
    changeTableThresholdDown = 3,
    name = "诈金花1元场",
    minrobot = 0,
   },
   -- [4]={
   --  changeTableThresholdUp = 20,
   --  rankScore = 5000,
   --  gameType = "zjh",
   --  roomID = 4005,
   --  maxCRobotCnt = 5,
   --  baseScore = 10000,
   --  minPlayer = 2,
   --  minScore = 1000000,
   --  leaveThresholdUp = 150,
   --  maxrobot = 0,
   --  maxOdds = 99999,
   --  compareHand = 2,
   --  escapeScore = 0,
   --  maxHand = 10,
   --  maxScore = 200000000,
   --  roomType = 1,
   --  leaveThresholdDown = 50,
   --  maxPlayer = 6,
   --  changeTableThresholdDown = 3,
   --  name = "诈金花100元场",
   --  minrobot = 0,
   -- },
   [3]={
    changeTableThresholdUp = 20,
    rankScore = 250,
    gameType = "zjh",
    roomID = 4003,
    maxCRobotCnt = 5,
    baseScore = 500,
    minPlayer = 2,
    minScore = 50000,
    leaveThresholdUp = 150,
    maxrobot = 17,
    maxOdds = 99999,
    compareHand = 2,
    escapeScore = 0,
    maxHand = 10,
    maxScore = 1000000,
    roomType = 1,
    leaveThresholdDown = 50,
    maxPlayer = 6,
    changeTableThresholdDown = 3,
    name = "诈金花5元场",
    minrobot = 0,
   },
   [1]={
    changeTableThresholdUp = 20,
    rankScore = 5,
    gameType = "zjh",
    roomID = 4001,
    maxCRobotCnt = 5,
    baseScore = 10,
    minPlayer = 2,
    minScore = 1000,
    leaveThresholdUp = 150,
    maxrobot = 17,
    maxOdds = 99999,
    compareHand = 2,
    escapeScore = 0,
    maxHand = 10,
    maxScore = 10000,
    roomType = 1,
    leaveThresholdDown = 50,
    maxPlayer = 6,
    changeTableThresholdDown = 3,
    name = "诈金花体验场",
    minrobot = 0,
   },
   -- [5]={
   --  changeTableThresholdUp = 20,
   --  rankScore = 1000,
   --  gameType = "zjh",
   --  roomID = 4004,
   --  maxCRobotCnt = 5,
   --  baseScore = 2000,
   --  minPlayer = 2,
   --  minScore = 200000,
   --  leaveThresholdUp = 150,
   --  maxrobot = 17,
   --  maxOdds = 99999,
   --  compareHand = 2,
   --  escapeScore = 0,
   --  maxHand = 10,
   --  maxScore = 20000000,
   --  roomType = 1,
   --  leaveThresholdDown = 50,
   --  maxPlayer = 6,
   --  changeTableThresholdDown = 3,
   --  name = "诈金花20元场",
   --  minrobot = 0,
   -- },
  },
  scale = 100,    --开始日期
  alms = {        --救济金
   count = 3, 
   condition = 400,
   gold = 500,
  },
 },
}

-- WEB_ROOT_URL = "http://xpt-head.htgames.cn:8998/index/"     外网测试环境
-- WEB_LOGIN_URL = WEB_ROOT_URL.."login/"
-- WEB_REGIST_URL = WEB_ROOT_URL.."regist/"
-- WEB_FORGOT_URL = WEB_ROOT_URL.."forgot/"
-- WEB_QUICK_URL = WEB_ROOT_URL.."guest/"
-- WEB_MARKET_URL = WEB_ROOT_URL.."pay"
-- WEB_SERVER_URL = "ws://121.41.31.67:9001/ws"
-- ROOM_CONFIG_URL = "http://client-update.htgames.cn/games/config/zjh_roomconfig.lua"
-- HEAD_GET_URL = "http://xpt-head.htgames.cn:8998"
-- HEAD_PUT_URL = "http://xpt-head.htgames.cn:8998/index/upload"
-- BACKSTAGE_URL = "http://qwadmin.htgames.cn/index.php/Qwadmin/Free/install.html"


WEB_ROOT_URL = "http://192.168.0.86:8998/index/" --内网测试环境
WEB_LOGIN_URL = WEB_ROOT_URL.."login/"
WEB_REGIST_URL = WEB_ROOT_URL.."regist/"
WEB_FORGOT_URL = WEB_ROOT_URL.."forgot/"
WEB_QUICK_URL = WEB_ROOT_URL.."guest/"
WEB_MARKET_URL = WEB_ROOT_URL.."pay"
WEB_SERVER_URL = "ws://192.168.0.85:9001/ws"       --连的是85 
-- WEB_SERVER_URL = "ws://10.101.1.154:9001/ws"    连的是景程服务器
ROOM_CONFIG_URL = "http://client-update.htgames.cn/games/config/zjh_roomconfig.lua"
HEAD_GET_URL = "http://xpt-head.htgames.cn:8998"
HEAD_PUT_URL = "http://xpt-head.htgames.cn:8998/index/upload"
BACKSTAGE_URL = "http://qwadmin.htgames.cn/index.php/Qwadmin/Free/install.html"
