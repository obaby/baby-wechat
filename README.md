# 微信双开脚本 (WeChat Dual Launch Script)

一个用于 macOS 系统的微信双开自动化脚本，通过复制微信应用并修改 Bundle ID 实现真正的微信双开功能。

## 📋 功能特性

- ✅ **一键双开** - 自动完成所有设置步骤
- ✅ **智能检测** - 自动检测已存在的 WeChat2.app
- ✅ **安全可靠** - 完善的错误处理和权限检查
- ✅ **彩色输出** - 友好的命令行界面
- ✅ **进程管理** - 查看和管理微信进程
- ✅ **自动化设置** - 无需手动执行复杂命令

## 🚀 快速开始

### 1. 下载脚本

```bash
# 克隆或下载脚本到本地
git clone <repository-url>
cd baby_wechat
```

### 2. 赋予执行权限

```bash
chmod +x baby_wechat.sh
```

### 3. 运行脚本

```bash
# 一键设置并启动微信双开（推荐）
./baby_wechat.sh auto
```

## 📖 使用方法

### 基本命令

```bash
# 自动设置并启动微信双开（首次使用推荐）
./baby_wechat.sh auto

# 仅设置微信双开环境
./baby_wechat.sh setup

# 仅启动微信双开（需要先设置环境）
./baby_wechat.sh start

# 查看当前运行的微信进程
./baby_wechat.sh -s

# 关闭所有微信进程
./baby_wechat.sh -k

# 显示帮助信息
./baby_wechat.sh -h
```

### 详细说明

| 命令 | 功能 | 说明 |
|------|------|------|
| `auto` | 自动设置并启动 | 首次使用推荐，自动完成所有步骤 |
| `setup` | 设置环境 | 创建 WeChat2.app 并配置 |
| `start` | 启动双开 | 启动原始微信和第二个微信 |
| `-s` | 查看进程 | 显示当前运行的微信进程 |
| `-k` | 关闭进程 | 关闭所有微信进程 |
| `-h` | 帮助信息 | 显示详细的使用说明 |

## 🔧 工作原理

脚本通过以下步骤实现微信双开：

1. **复制应用** - 将 `/Applications/WeChat.app` 复制为 `/Applications/WeChat2.app`
2. **修改Bundle ID** - 将第二个微信的 Bundle ID 改为 `com.tencent.xinWeChat2`
3. **重新签名** - 使用 `codesign` 重新签名应用
4. **启动双开** - 分别启动原始微信和第二个微信

## 📋 系统要求

- **操作系统**: macOS 10.12 或更高版本
- **微信版本**: 已安装微信 macOS 客户端
- **开发工具**: Xcode 命令行工具
- **权限**: 管理员权限（用于复制和修改应用）

## ⚠️ 注意事项

### 安装 Xcode 命令行工具

如果遇到 `PlistBuddy` 未找到的错误，请先安装 Xcode 命令行工具：

```bash
xcode-select --install
```

### 权限要求

脚本需要管理员权限来：
- 复制微信应用到 `/Applications/` 目录
- 修改应用的 Bundle ID
- 重新签名应用

### 安全提醒

- 脚本会修改系统应用，请确保从可信来源下载
- 建议在运行前备份重要数据
- 如果遇到问题，可以手动删除 `/Applications/WeChat2.app`

## 🛠️ 故障排除

### 常见问题

1. **"未找到 PlistBuddy" 错误**
   ```bash
   xcode-select --install
   ```

2. **"权限被拒绝" 错误**
   - 确保使用管理员权限运行
   - 检查系统偏好设置中的安全设置

3. **"WeChat2.app 创建失败"**
   - 检查磁盘空间是否充足
   - 确保微信应用完整且未损坏

4. **"重新签名失败"**
   - 确保已安装 Xcode 命令行工具
   - 检查网络连接（可能需要下载证书）

### 手动清理

如果需要手动清理，可以执行：

```bash
# 删除 WeChat2.app
sudo rm -rf /Applications/WeChat2.app

# 关闭所有微信进程
pkill -f WeChat
```

## 📝 更新日志

### v1.0.0 (2025-08-14)
- ✨ 初始版本发布
- ✨ 支持微信双开功能
- ✨ 自动化设置流程
- ✨ 进程管理功能
- ✨ 彩色命令行界面

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目。

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 🔗 相关链接

- **作者网站**: https://oba.by
- **技术博客**: https://h4ck.org.cn

## ⭐ 支持

如果这个项目对你有帮助，请给它一个星标 ⭐

---

**免责声明**: 本脚本仅供学习和研究使用。使用本脚本产生的任何后果由用户自行承担。
