#!/bin/bash

# 微信双开脚本
# obaby
# 2025-08-14
# 使用方法:
# 1. 下载脚本到本地
# 2. 赋予脚本执行权限
# 3. 运行脚本
# 4. 按照提示操作
# 5. 完成
# https://oba.by
# https://h4ck.org.cn

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 微信应用路径 (macOS)
WECHAT_APP="/Applications/WeChat.app"
WECHAT2_APP="/Applications/WeChat2.app"
WECHAT_EXECUTABLE="/Applications/WeChat.app/Contents/MacOS/WeChat"
WECHAT2_EXECUTABLE="/Applications/WeChat2.app/Contents/MacOS/WeChat"

# 检查微信是否已安装
check_wechat_installation() {
    if [ ! -d "$WECHAT_APP" ]; then
        echo -e "${RED}错误: 未找到微信应用，请确保微信已安装在 /Applications/WeChat.app${NC}"
        exit 1
    fi
    
    if [ ! -f "$WECHAT_EXECUTABLE" ]; then
        echo -e "${RED}错误: 未找到微信可执行文件${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ 微信应用检查通过${NC}"
}

# 检查是否已存在WeChat2.app
check_wechat2_exists() {
    if [ -d "$WECHAT2_APP" ]; then
        echo -e "${YELLOW}检测到已存在 WeChat2.app${NC}"
        return 0
    else
        echo -e "${BLUE}未检测到 WeChat2.app，需要创建${NC}"
        return 1
    fi
}

# 删除已存在的WeChat2.app
remove_wechat2() {
    echo -e "${YELLOW}正在删除已存在的 WeChat2.app...${NC}"
    
    if [ -d "$WECHAT2_APP" ]; then
        sudo rm -rf "$WECHAT2_APP"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ WeChat2.app 删除成功${NC}"
        else
            echo -e "${RED}✗ WeChat2.app 删除失败${NC}"
            return 1
        fi
    fi
}

# 复制微信应用创建WeChat2.app
copy_wechat_app() {
    echo -e "${YELLOW}正在复制微信应用创建 WeChat2.app...${NC}"
    echo -e "${BLUE}这可能需要一些时间，请耐心等待...${NC}"
    
    sudo cp -R "$WECHAT_APP" "$WECHAT2_APP"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ WeChat2.app 创建成功${NC}"
        return 0
    else
        echo -e "${RED}✗ WeChat2.app 创建失败${NC}"
        return 1
    fi
}

# 修改Bundle ID
modify_bundle_id() {
    echo -e "${YELLOW}正在修改 WeChat2.app 的 Bundle ID...${NC}"
    
    # 检查是否安装了Xcode命令行工具
    if ! command -v /usr/libexec/PlistBuddy &> /dev/null; then
        echo -e "${RED}错误: 未找到 PlistBuddy，请先安装 Xcode 命令行工具${NC}"
        echo -e "${YELLOW}安装命令: xcode-select --install${NC}"
        return 1
    fi
    
    sudo /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.tencent.xinWeChat2" "$WECHAT2_APP/Contents/Info.plist"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Bundle ID 修改成功${NC}"
        return 0
    else
        echo -e "${RED}✗ Bundle ID 修改失败${NC}"
        return 1
    fi
}

# 重新签名应用
resign_app() {
    echo -e "${YELLOW}正在重新签名 WeChat2.app...${NC}"
    
    sudo codesign --force --deep --sign - "$WECHAT2_APP"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ WeChat2.app 重新签名成功${NC}"
        return 0
    else
        echo -e "${RED}✗ WeChat2.app 重新签名失败${NC}"
        return 1
    fi
}

# 检查微信进程
check_wechat_processes() {
    local count=$(ps aux | grep -v grep | grep -c "WeChat")
    echo -e "${BLUE}当前运行的微信进程数: $count${NC}"
    return $count
}

# 关闭所有微信进程
kill_all_wechat() {
    echo -e "${YELLOW}正在关闭所有微信进程...${NC}"
    
    local pids=$(ps aux | grep -v grep | grep "WeChat" | awk '{print $2}')
    
    if [ -z "$pids" ]; then
        echo -e "${BLUE}没有找到运行中的微信进程${NC}"
        return
    fi
    
    for pid in $pids; do
        echo -e "${YELLOW}正在关闭进程 PID: $pid${NC}"
        kill -TERM $pid 2>/dev/null
    done
    
    # 等待进程结束
    sleep 2
    
    # 强制杀死仍在运行的进程
    local remaining_pids=$(ps aux | grep -v grep | grep "WeChat" | awk '{print $2}')
    if [ ! -z "$remaining_pids" ]; then
        echo -e "${YELLOW}强制关闭剩余进程...${NC}"
        for pid in $remaining_pids; do
            kill -KILL $pid 2>/dev/null
        done
    fi
    
    echo -e "${GREEN}✓ 所有微信进程已关闭${NC}"
}

# 启动原始微信
start_original_wechat() {
    echo -e "${YELLOW}正在启动原始微信...${NC}"
    
    open "$WECHAT_APP"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ 原始微信启动成功${NC}"
        return 0
    else
        echo -e "${RED}✗ 原始微信启动失败${NC}"
        return 1
    fi
}

# 启动第二个微信
start_second_wechat() {
    echo -e "${YELLOW}正在启动第二个微信...${NC}"
    
    if [ ! -f "$WECHAT2_EXECUTABLE" ]; then
        echo -e "${RED}错误: 未找到 WeChat2.app 的可执行文件${NC}"
        return 1
    fi
    
    nohup "$WECHAT2_EXECUTABLE" >/dev/null 2>&1 &
    local pid=$!
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ 第二个微信启动成功 (PID: $pid)${NC}"
        return 0
    else
        echo -e "${RED}✗ 第二个微信启动失败${NC}"
        return 1
    fi
}

# 显示当前运行的微信进程
show_running_instances() {
    echo -e "${BLUE}当前运行的微信进程:${NC}"
    ps aux | grep -v grep | grep "WeChat" | while read line; do
        echo -e "${YELLOW}  $line${NC}"
    done
}

# 设置微信双开
setup_wechat_dualkai() {
    echo -e "${BLUE}开始设置微信双开...${NC}"
    
    # 检查微信安装
    check_wechat_installation
    
    # 关闭所有微信进程
    kill_all_wechat
    
    # 检查并删除已存在的WeChat2.app
    if check_wechat2_exists; then
        read -p "检测到已存在 WeChat2.app，是否删除并重新创建？(y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            remove_wechat2
        else
            echo -e "${YELLOW}跳过删除步骤，继续使用现有的 WeChat2.app${NC}"
        fi
    fi
    
    # 如果WeChat2.app不存在，则创建
    if [ ! -d "$WECHAT2_APP" ]; then
        echo -e "${BLUE}需要创建 WeChat2.app...${NC}"
        
        # 复制微信应用
        copy_wechat_app
        if [ $? -ne 0 ]; then
            echo -e "${RED}创建 WeChat2.app 失败，退出${NC}"
            exit 1
        fi
        
        # 修改Bundle ID
        modify_bundle_id
        if [ $? -ne 0 ]; then
            echo -e "${RED}修改 Bundle ID 失败，退出${NC}"
            exit 1
        fi
        
        # 重新签名
        resign_app
        if [ $? -ne 0 ]; then
            echo -e "${RED}重新签名失败，退出${NC}"
            exit 1
        fi
        
        echo -e "${GREEN}✓ WeChat2.app 设置完成${NC}"
    else
        echo -e "${GREEN}✓ 使用现有的 WeChat2.app${NC}"
    fi
}

# 启动微信双开
start_wechat_dualkai() {
    echo -e "${BLUE}启动微信双开...${NC}"
    
    # 启动原始微信
    start_original_wechat
    
    # 等待一下
    sleep 2
    
    # 启动第二个微信
    start_second_wechat
    
    # 等待一下然后显示所有进程
    sleep 2
    show_running_instances
    
    echo -e "${GREEN}✓ 微信双开启动完成！${NC}"
    echo -e "${BLUE}现在你应该能看到两个微信窗口${NC}"
}

# 显示帮助信息
show_help() {
    echo -e "${BLUE}微信双开脚本使用说明:${NC}"
    echo ""
    echo -e "${YELLOW}用法:${NC}"
    echo "  $0 [选项]"
    echo ""
    echo -e "${YELLOW}选项:${NC}"
    echo "  setup         设置微信双开环境（创建WeChat2.app）"
    echo "  start         启动微信双开"
    echo "  auto          自动设置并启动微信双开"
    echo "  -s            显示当前运行的微信进程"
    echo "  -k            关闭所有微信进程"
    echo "  -h            显示此帮助信息"
    echo ""
    echo -e "${YELLOW}示例:${NC}"
    echo "  $0 setup       # 设置微信双开环境"
    echo "  $0 start       # 启动微信双开"
    echo "  $0 auto        # 自动设置并启动微信双开"
    echo "  $0 -s          # 显示运行中的微信进程"
    echo "  $0 -k          # 关闭所有微信进程"
    echo ""
    echo -e "${YELLOW}注意:${NC}"
    echo "  首次使用建议运行 '$0 auto' 来自动完成所有设置"
    echo "  需要管理员权限来创建和修改应用"
    echo "  需要安装 Xcode 命令行工具"
    echo ""
}

# 主函数
main() {
    # 检查参数
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    case "$1" in
        setup)
            setup_wechat_dualkai
            ;;
        start)
            start_wechat_dualkai
            ;;
        auto)
            setup_wechat_dualkai
            start_wechat_dualkai
            ;;
        -s)
            show_running_instances
            ;;
        -k)
            kill_all_wechat
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo -e "${RED}无效的参数: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 脚本入口
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
