# PortReleasor 使用指南

## 简介 (Description)
PortReleasor 是一个 PowerShell 脚本，用于帮助用户在 Windows 系统上查找并终止使用特定端口的进程。它支持子字符串匹配功能，允许用户只需输入 "808" 即可终止使用端口 8080、8081、8089 等的进程。

## 功能特性 (Features)
- ✅ **子字符串匹配**：输入 "808" 可匹配端口 8080、8081、8089 等
- ✅ **IPv6 支持**：同时处理 IPv4 (127.0.0.1:8080) 和 IPv6 ([::1]:8080) 地址格式
- ✅ **用户友好界面**：显示清晰的进程编号列表
- ✅ **安全确认**：在终止进程前需要用户明确确认
- ✅ **调试模式**：使用 `-Debug` 参数获取详细的调试输出
- ✅ **详细反馈**：显示每个进程的操作成功/失败状态
- ✅ **汇总报告**：提供操作结果的最终概览
- ✅ **错误处理**：优雅处理边界情况和权限问题

## 系统要求 (Requirements)
- Windows 操作系统
- PowerShell（Windows 自带）
- 管理员权限（推荐用于终止进程）

## 使用方法 (Usage)

### 运行脚本：
```powershell
# 运行脚本（将提示输入端口）
.\PortReleasor.ps1

# 直接指定端口参数
.\PortReleasor.ps1 -PortInput "808"

# 使用调试模式运行以获取详细故障排除信息
.\PortReleasor.ps1 -PortInput "808" -Debug
```

### 逐步使用说明：
1. **启动脚本**：双击脚本或在 PowerShell 中运行
2. **输入端口号**：输入端口号或部分端口号（例如，对于 8080、8081 等，输入"808"）
3. **查看进程**：查看使用匹配端口的进程列表
4. **确认操作**：输入 'Y' 确认终止所有进程，或输入 'N' 取消
5. **查看结果**：查看哪些进程成功终止，哪些终止失败

## 示例 (Examples)

### 示例 1：终止所有使用端口 3000 的进程
```powershell
.\PortReleasor.ps1
# 输入：3000
# 脚本将查找并终止使用端口 3000 的进程
```

### 示例 2：终止所有使用以 808 开头的端口的进程
```powershell
.\PortReleasor.ps1 -PortInput "808"
# 脚本将查找使用端口 8080、8081、8082 等的进程
```

## 安全特性 (Safety Features)
- **需要确认**：脚本不会在没有用户确认的情况下终止任何进程
- **详细输出**：在继续操作前显示将要终止的确切进程
- **错误处理**：不会因权限错误或缺少进程而崩溃
- **清晰反馈**：每个进程操作的成功/失败状态

## 故障排除 (Troubleshooting)

### 权限被拒绝错误 (Permission Denied Errors)
如果遇到权限错误，请以管理员身份运行 PowerShell：
```powershell
# 右键点击 PowerShell > 以管理员身份运行
cd "F:\C0de\SLabs\SWinScripts\portReleasor"
.\PortReleasor.ps1
```

### 未找到进程 (No Processes Found)
- 确保端口正被某个进程使用
- 尝试更广泛的搜索词（例如，用"80"而不用"8080"）
- 检查应用程序是否仍在运行
- 使用调试模式查看 netstat 详情：`.\PortReleasor.ps1 -PortInput "8080" -Debug`

### 调试模式 (Debug Mode)
使用 `-Debug` 参数进行详细故障排除：
```powershell
.\PortReleasor.ps1 -PortInput "808" -Debug
```
调试模式显示：
- 原始 netstat 连接信息
- 连接解析详情
- 端口提取过程
- 进程查找结果
- 解析链中的任何失败

### 错误消息 (Error Messages)
脚本为以下情况提供清晰的错误消息：
- 无效的端口号（非数字输入）
- 权限问题
- 网络连接错误
- 进程终止失败

## 技术细节 (Technical Details)
- 使用 `netstat -ano` 查找活动的 TCP 连接
- 同时处理 IPv4 (127.0.0.1:8080) 和 IPv6 ([::1]:8080) 地址格式
- 具有变量空白处理的健壮解析
- 解析输出以识别进程 ID (PID) 和进程名称
- 使用 `taskkill /PID <pid> /F` 强制终止进程
- 跟踪并报告每个终止操作的成功/失败

## 技术支持 (Technical Support)
如果遇到问题或有功能建议，请：
1. 首先尝试使用 `-Debug` 参数获取详细信息
2. 检查 PowerShell 执行策略：`Get-ExecutionPolicy`
3. 确保以管理员身份运行
4. 查看 GitHub 仓库的 Issues 页面获取已知问题和解决方案
