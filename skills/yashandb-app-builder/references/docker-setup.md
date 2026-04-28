# Docker 创建 YashanDB

## 概述

本文档介绍如何使用 Docker 创建和运行 YashanDB 服务。

## 前置条件

- Docker 已安装
- Docker 服务已启动

如未安装 Docker，请先执行 `/docker-installer` 安装。

## 快速开始

### 拉取 YashanDB 镜像

```bash
# 拉取最新镜像（推荐）
docker pull yashandb/yashandb:22.2.5.100

# 或拉取毫秒版本
docker pull yashandb/yashandb:22.2.5.100-ms
```

### 创建并启动容器

```bash
# 创建 YashanDB 容器
docker run -d \
  --name yashandb \
  -p 1688:1688 \
  -e YASHDB_PASSWORD=your_password \
  yashandb/yashandb:22.2.5.100
```

### 参数说明

| 参数 | 说明 |
|------|------|
| `--name` | 容器名称 |
| `-p` | 端口映射（主机端口:容器端口） |
| `-e` | 环境变量 |
| `YASHDB_PASSWORD` | 数据库密码 |

## 常用操作

### 查看容器状态

```bash
# 查看运行中的容器
docker ps

# 查看所有容器（包括已停止）
docker ps -a
```

### 启动/停止容器

```bash
# 启动容器
docker start yashandb

# 停止容器
docker stop yashandb

# 重启容器
docker restart yashandb
```

### 查看日志

```bash
# 查看容器日志
docker logs yashandb

# 实时查看日志
docker logs -f yashandb
```

### 进入容器

```bash
# 进入容器交互式终端
docker exec -it yashandb /bin/bash
```

### 连接 YashanDB

#### 使用 yasql 命令行工具

```bash
# 进入容器
docker exec -it yashandb /bin/bash

# 连接数据库
yasql sys/password@localhost:1688
```

#### 外部连接

| 参数 | 值 |
|------|-----|
| 主机 | localhost |
| 端口 | 1688 |
| 用户名 | sys |
| 密码 | your_password |
| 数据库 | yashandb |

## 数据持久化

### 方式一：使用卷

```bash
# 创建卷
docker volume create yashandb_data

# 使用卷启动容器
docker run -d \
  --name yashandb \
  -p 1688:1688 \
  -v yashandb_data:/yashanDB/yashandb-22.2.5.100/data \
  -e YASHDB_PASSWORD=your_password \
  yashandb/yashandb:22.2.5.100
```

### 方式二：绑定宿主机目录

```bash
# 创建宿主机目录
mkdir -p /home/hhl/yashandb/data

# 绑定目录启动
docker run -d \
  --name yashandb \
  -p 1688:1688 \
  -v /home/hhl/yashandb/data:/yashanDB/yashandb-22.2.5.100/data \
  -e YASHDB_PASSWORD=your_password \
  yashandb/yashandb:22.2.5.100
```

## 完整示例

### docker-compose 方式（推荐）

创建 `docker-compose.yml`：

```yaml
version: '3.8'

services:
  yashandb:
    image: yashandb/yashandb:22.2.5.100
    container_name: yashandb
    ports:
      - "1688:1688"
    environment:
      - YASHDB_PASSWORD=your_password
    volumes:
      - yashandb_data:/yashanDB/yashandb-22.2.5.100/data
    restart: unless-stopped

volumes:
  yashandb_data:
```

启动服务：

```bash
# 启动
docker-compose up -d

# 停止
docker-compose down

# 查看日志
docker-compose logs -f
```

## 常见问题

### 1. 端口被占用

```bash
# 查找占用 1688 端口的进程
lsof -i :1688

# 修改端口映射
-p 1689:1688
```

### 2. 容器启动失败

```bash
# 查看错误日志
docker logs yashandb

# 检查磁盘空间
df -h
```

### 3. 无法连接数据库

```bash
# 检查容器是否运行
docker ps | grep yashandb

# 检查端口是否监听
netstat -tlnp | grep 1688
```

## 相关文档

- [部署指南](deployment.md)
- `/yashandb-docker` - Docker 部署 YashanDB 技能
- `/docker-installer` - Docker 安装技能
