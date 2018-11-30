# 常用的脚本封装

## dayone2 cli的脚本封装
> 模板可以自己修改,执行脚本后，只有输入y才开始执行

- alias dy="/xx/xx/xx/xx/day_one.sh" 
- 将上面的代码加入.zshrc，执行source .zshrc
- 赋予脚本执行权限， chmod a+x /xx/xx/xx/xx/day_one.sh
- 开始写日记 ，执行命令 `dy`


## sdaswap
> 用于对华硕路由器ac86u的内存不足情况做一个虚拟内存
> 脚本755权限，放置于路由器目录 /jffs/scripts/ 下

- /jffs/scripts/swaswap info
- /jffs/scripts/swaswap start
- /jffs/scripts/swaswap stop
