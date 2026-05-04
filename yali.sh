#!/bin/bash

# 服务器CPU与内存测压脚本（基于 stress-ng）
# ===================== 配置区 =====================
CPU_CORES=""        # 需要压测的CPU核心数，留空或设为0则自动使用全部核心
CPU_LOAD=100        # CPU负载百分比（0-100），100表示满载，50表示单核一半负载
MEM_MB=100         # 需要占用的内存大小（单位：MB）
DURATION_MIN=1      # 测试持续时长（单位：分钟）
# ===================== 配置区结束 =====================

# ---------- 预处理配置 ----------
# 若CPU_CORES为空或0，则获取系统全部核心数
if [ -z "$CPU_CORES" ] || [ "$CPU_CORES" -eq 0 ]; then
    CPU_CORES=$(nproc)
fi

# 限制 CPU_LOAD 在 0-100 之间
if [ "$CPU_LOAD" -lt 0 ]; then CPU_LOAD=0; fi
if [ "$CPU_LOAD" -gt 100 ]; then CPU_LOAD=100; fi

# 将分钟转换为秒
TIMEOUT_SEC=$(( DURATION_MIN * 60 ))

# ---------- 自动安装 stress-ng ----------
if ! command -v stress-ng &>/dev/null; then
    echo "stress-ng 未安装，正在尝试自动安装..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y stress-ng
    elif command -v yum &>/dev/null; then
        sudo yum install -y stress-ng
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y stress-ng
    else
        echo "未找到支持的包管理器，请手动安装 stress-ng 后重试。"
        exit 1
    fi
fi

# ---------- 开始压力测试 ----------
echo "=========================================="
echo "服务器压力测试开始"
echo "CPU核心数 : $CPU_CORES (负载: ${CPU_LOAD}%)"
echo "内存占用  : ${MEM_MB}MB"
echo "测试时长  : ${DURATION_MIN} 分钟 (${TIMEOUT_SEC}秒)"
echo "=========================================="

# 启动 stress-ng 并隐藏所有输出
stress-ng --cpu "$CPU_CORES" \
          --cpu-load "$CPU_LOAD" \
          --vm 1 --vm-bytes "${MEM_MB}M" --vm-keep \
          --timeout "${TIMEOUT_SEC}s" \
          --quiet > /dev/null 2>&1 &
STRESS_PID=$!

START_TIME=$(date +%s)
END_TIME=$(( START_TIME + TIMEOUT_SEC ))

# 实时倒计时循环
while true; do
    NOW=$(date +%s)
    REMAIN=$(( END_TIME - NOW ))
    if [ $REMAIN -le 0 ]; then
        break
    fi

    H=$(( REMAIN / 3600 ))
    M=$(( (REMAIN % 3600) / 60 ))
    S=$(( REMAIN % 60 ))

    # 原地刷新显示剩余时间
    printf "\r剩余时间：[%d小时 %d分钟 %d秒] " "$H" "$M" "$S"

    sleep 1

    # 如果 stress-ng 意外退出，提前终止倒计时
    if ! kill -0 $STRESS_PID 2>/dev/null; then
        break
    fi
done

# 等待进程完全退出
wait $STRESS_PID 2>/dev/null

printf "\n压力测试完成。\n"
