# 安装指南

本指南介绍如何安装 yashandb-sqlalchemy 方言包。

## 前置要求

- Python 3.8+
- YashanDB 23.1.1+
- SQLAlchemy 2.0.50（建议采用）
- yaspy >=1.2.1

## 重要说明

yashandb-sqlalchemy 是 **SQLAlchemy 的方言扩展**，需要依赖 SQLAlchemy 核心包。安装时需要注意版本兼容性：

- **SQLAlchemy 版本**：建议采用 **2.0.50**（2.0.0 之后版本可能兼容，未做测试）
- **yaspy 版本**：>=1.2.1

## 安装步骤

### 步骤 1：安装 SQLAlchemy（建议采用 2.0.50）

```bash
pip3 install "SQLAlchemy==2.0.50"
```

### 步骤 2：安装 yaspy 驱动（推荐 1.2.1 或更高版本）

```bash
pip3 install yaspy==1.2.1
```

### 步骤 3：安装 yashandb-sqlalchemy

```bash
pip3 install yashandb-sqlalchemy
```

### 步骤 4：验证安装

```python
import yashandb_sqlalchemy
from sqlalchemy import create_engine

# 测试连接
engine = create_engine("yashandb+yaspy://sys:password@127.0.0.1:1688/test")
print(engine.connect())
```

## 依赖说明

| 包名 | 版本要求 | 说明 |
|------|----------|------|
| Python | 3.8+ | 推荐 3.11 |
| **SQLAlchemy** | 建议采用 2.0.50 | 2.0.0 之后版本可能兼容，未做测试 |
| **yaspy** | >=1.2.1 | YashanDB Python 驱动 |
| yashandb-sqlalchemy | 2.0.0 | YashanDB 方言包 |

## 一键安装（推荐）

可以一次性安装所有依赖：

```bash
pip3 install "SQLAlchemy==2.0.50" yaspy==1.2.1 yashandb-sqlalchemy==2.0.0
```

## 源码安装（可选）

如需安装最新开发版本：

```bash
# 安装 SQLAlchemy 2.0.50
pip3 install "SQLAlchemy==2.0.50"

# 安装 yaspy 1.2.1
pip3 install yaspy==1.2.1

# 克隆并安装 yashandb-sqlalchemy
git clone https://github.com/yashan-technologies/yashandb-sqlalchemy.git
cd yashandb-sqlalchemy
pip3 install -e .
```

## 卸载

```bash
pip3 uninstall yashandb-sqlalchemy
# SQLAlchemy 和 yaspy 如不需要可保留
```
