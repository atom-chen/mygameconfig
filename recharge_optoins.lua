local t = {
    {
        money = 1,
        item_type = 1,--1=金币   2=红包  3=钻石
        num = 10000,
        icon_path = "1",
        cost_scale = 10000,
        addition = 0,
        product_id = 10001
    },    
    {
        money = 3,
        item_type = 1,--1=金币   2=红包  3=钻石
        num = 30000,
        icon_path = "1",
        cost_scale = 10000,
        addition = 0,
        product_id = 10002
    },
    {
        money = 10,
        item_type = 1,--1=金币   2=红包  3=钻石
        num = 100000,
        icon_path = "2",
        cost_scale = 10000,
        addition = 0,
        product_id = 10003
    },
    {
        money = 20,
        item_type = 1,--1=金币   2=红包  3=钻石
        num = 200000,
        icon_path = "3",
        cost_scale = 10000,
        addition = 0,
        product_id = 10004
    },
    {
         money = 50,
         item_type = 1,--1=金币   2=红包  3=钻石
         num = 500000,
         icon_path = "4",
         cost_scale = 10000,
         addition = 0,
         product_id = 10005
    },
    {
        money = 100,
        item_type = 1,--1=金币   2=红包  3=钻石
        num = 1100000,
        icon_path = "5",
        cost_scale = 11000,
        addition = 10,
        product_id = 10006
    },
    {
        money = 6,
        item_type = 1,--1=金币   2=红包  3=钻石
        num = 60000,
        icon_path = "2",
        cost_scale = 10000,
        addition = 0,
        product_id = 10007,
        firstrecharge = 1 --首充
    },
    {
        money = 6,
        item_type = 3,--1=金币   2=红包  3=钻石
        num = 72,
        goods = "3:60",
        addition_goods = "3:12|2:24",
        icon_path = "11",
        cost_scale = 12,
        addition = 20,
        product_id = 10009
    },

    {
        money = 6,  --60钻=6元
        item_type = 3,--1=金币   2=红包  3=钻石
        num = 60,
        goods = "3:60",
        icon_path = "11",
        cost_scale = 10,
        addition = 0,
        product_id = 10011
    },
    {
        money = 18, --180钻=18元
        item_type = 3,--1=金币   2=红包  3=钻石
        num = 180,
        goods = "3:180",
        icon_path = "11",
        cost_scale = 10,
        addition = 0,
        product_id = 10012
    },

    --{
    --    money = 30, --300钻=30元
    --    item_type = 3,--1=金币   2=红包  3=钻石
    --    num = 300,
    --    goods = "3:300",
    --    icon_path = "11",
    --    cost_scale = 10,
    --    addition = 0,
    --    product_id = 10013
    --},

    {
        money = 50,--600钻=50元
        item_type = 3,--1=金币   2=红包  3=钻石
        num = 550,
        goods = "3:500",
        icon_path = "11",
        cost_scale = 11,
        addition = 10,
        product_id = 10014
    },
    {
        money = 100,--1200钻=100元
        item_type = 3,--1=金币   2=红包  3=钻石
        num = 1200,
        goods = "3:1200",
        icon_path = "11",
        cost_scale = 12,
        addition = 20,
        product_id = 10015
    },
    {
        money = 2,--20钻2元(红包余额兑换)
        item_type = 3,--1=金币   2=红包  3=钻石
        num = 20,
        goods = "3:20",
        icon_path = "11",
        cost_scale = 0,
        addition = 0,
        product_id = 0,
        id = 8

    },
    {
        money = 5,--62钻5元(红包余额兑换)
        item_type = 3,--1=金币   2=红包  3=钻石
        num = 62,
        goods = "3:62",
        icon_path = "11",
        cost_scale = 10.4,
        addition = 24,
        product_id = 0,
        id = 9
    }--,
    --{
    --    money = 8,
    --    item_type = 3,--1=金币   2=红包  3=钻石
    --    num = 96,
    --    goods = "3:80",
    --    addition_goods = "3:16|2:24",
    --    cost_scale = 12,
    --    icon_path = "11",
    --    addition = 20,
    --    product_id = 10010
    --}
}

return t