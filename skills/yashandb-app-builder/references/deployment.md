# 部署指南

## 概述

本文档介绍 YashanDB 应用的本地部署流程，包括后端服务启动、前端服务启动和访问验证。

## 部署流程

### 步骤 1：确保 YashanDB 服务运行

在部署应用之前，必须确保 YashanDB 数据库服务正常运行。

```bash
# 检查 YashanDB 容器状态
docker ps | grep yashandb

# 如果未运行，启动容器
docker start yashandb
```

### 步骤 2：启动后端服务

#### Golang 项目

```bash
# 方式一：直接运行
go run ./cmd/api

# 方式二：使用 Makefile
make run

# 方式三：编译后运行
make build
./bin/api
```

#### Python 项目

```bash
# 方式一：使用 uvicorn
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 方式二：使用 Python
python -m app.main

# 方式三：后台运行
nohup uvicorn app.main:app --host 0.0.0.0 --port 8000 > server.log 2>&1 &
```

### 步骤 3：启动前端开发服务器

```bash
# 进入前端目录
cd frontend

# 安装依赖（如首次运行）
npm install

# 启动开发服务器
npm run dev
```

### 步骤 4：验证部署

#### 检查后端服务

```bash
# 测试 API 是否正常
curl http://localhost:8000/

# 或使用浏览器访问
http://localhost:8000/
```

#### 检查前端服务

打开浏览器访问：
```
http://localhost:5173/
```

## 环境配置

### 开发环境配置

#### Golang (.env)

```bash
DATABASE_HOST=localhost
DATABASE_PORT=1688
DATABASE_USER=sys
DATABASE_PASSWORD=your_password
DATABASE_NAME=yashandb
```

#### Python (.env)

```python
DATABASE_URL=yashandb+yaspy://sys:password@localhost:1688/test
```

### 生产环境配置

**注意**：生产环境需要修改以下配置：

1. **修改默认端口**：避免使用 8000 端口
2. **启用 HTTPS**：使用 SSL/TLS 证书
3. **配置防火墙**：只开放必要端口
4. **日志管理**：配置日志输出到文件

## 常见问题

### 1. 端口被占用

```bash
# 查找占用端口的进程
lsof -i :8000

# 杀死进程
kill -9 <PID>
```

### 2. 数据库连接失败

```bash
# 检查 YashanDB 服务状态
docker ps | grep yashandb

# 检查连接信息
# 确认 host、port、user、password 是否正确
```

### 3. 前端无法访问后端 API

检查前端配置中的 API 基础地址是否正确：

```javascript
// 前端 .env 文件
VITE_API_BASE_URL=http://localhost:8000
```

## 交付清单

完成部署后，向用户确认以下内容：

- [ ] 后端服务已启动
- [ ] 前端服务已启动
- [ ] 数据库连接正常
- [ ] 核心功能可正常使用
- [ ] 提供访问地址

## 访问地址示例

| 服务 | 地址 |
|------|------|
| 后端 API | http://localhost:8000 |
| API 文档 | http://localhost:8000/docs |
| 前端页面 | http://localhost:5173 |

## 相关文档

- [Golang 项目布局](golang-project-layout.md)
- [Python 项目布局](python-project-layout.md)
- [Docker 创建 YashanDB](docker-setup.md)
