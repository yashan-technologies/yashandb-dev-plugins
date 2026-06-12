# Python 驱动安装详细指南

## 检查环境

### 检查 Python

```bash
python --version
pip --version
```

### 检查 C 驱动

```bash
ls ~/.yashandb/client/lib/libyascli.so 2>/dev/null && echo "已安装"
```

### Windows (PowerShell)

```powershell
Test-Path "$env:USERPROFILE\.yashandb\client\lib\yascli.dll"
```

如果 C 驱动未安装，执行 `/yashandb-c` 安装。

## 安装 Python

### Windows

```powershell
winget install Python.Python.3.12 --accept-source-agreements --accept-package-agreements
```

### Linux

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install python3 python3-pip

# CentOS/RHEL
sudo yum install python3 python3-pip
```

## 安装 Python 驱动

推荐从 PyPI 直接安装 **yaspy**（YashanDB Python 驱动）：

```bash
# 安装最新版本
pip install yaspy

# 安装推荐版本 1.2.1
pip install yaspy==1.2.1
```

### 驱动信息

| 属性 | 值 |
|------|-----|
| 推荐包名 | yaspy |
| 替代包名 | yasdb |
| 推荐版本 | 1.2.1 |
| Python 版本要求 | 3.6.0 及以上 |
| DB-API 版本 | 2.0 |
| 线程安全级别 | 2 |
| 参数风格 | 位置参数 (`:1`, `:2`) |
| 默认端口 | 1688 |
| 连接池支持 | 仅 yaspy 支持 |