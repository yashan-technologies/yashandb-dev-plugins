# Golang 项目布局

## 概述

本文档详细介绍基于 YashanDB 的 Golang 项目标准布局，遵循 [golang-standards/project-layout](https://github.com/golang-standards/project-layout) 规范。

## 项目结构

```
project-name/
├── cmd/                        # 应用程序入口
│   └── api/
│       └── main.go             # 主程序入口
├── internal/                   # 私有代码（不可被外部导入）
│   ├── handler/                # HTTP 处理层
│   ├── service/                # 业务逻辑层
│   ├── repository/             # 数据访问层
│   └── models/                 # 数据模型
├── pkg/                        # 可被外部导入的包
├── configs/                    # 配置文件
├── database/                   # 数据库相关
│   └── migrations/             # 数据库迁移脚本
├── api/                        # API 定义（OpenAPI/Swagger）
├── web/                        # Web 前端资源
│   ├── static/                 # 静态文件
│   └── templates/              # HTML 模板
├── go.mod                      # Go 模块依赖
├── go.sum                      # 依赖校验
└── Makefile                    # 构建脚本
```

## 目录说明

### cmd/

应用程序入口点。每个子目录对应一个可执行程序。

```go
// cmd/api/main.go
package main

import (
    "log"
    "github.com/your-org/project/internal/handler"
)

func main() {
    if err := handler.Start(); err != nil {
        log.Fatal(err)
    }
}
```

### internal/

私有代码库，不能被外部应用导入。

```
internal/
├── handler/     # HTTP 请求处理
├── service/     # 业务逻辑
├── repository/  # 数据访问层
└── models/      # 数据模型定义
```

### pkg/

可被外部应用导入的公共库。

### configs/

配置文件目录。

```yaml
# configs/config.yaml
database:
  host: localhost
  port: 1688
  user: sys
  password: password
  dbname: yashandb
```

### database/

数据库相关文件。

```
database/
└── migrations/
    └── 001_init.sql
```

### api/

API 定义文件（OpenAPI/Swagger 规范）。

### web/

静态 Web 资源。

## 分层架构

```
┌─────────────┐
│   Handler   │  ← HTTP 请求处理
└──────┬──────┘
       │
┌──────▼──────┐
│   Service   │  ← 业务逻辑
└──────┬──────┘
       │
┌──────▼──────┐
│ Repository  │  ← 数据访问
└──────┬──────┘
       │
┌──────▼──────┐
│    GORM     │  ← 数据库操作
└─────────────┘
```

## GORM 连接配置

在 `internal/repository` 中初始化 GORM 连接：

```go
package repository

import (
    "gorm.io/driver/yashandb"
    "gorm.io/gorm"
)

var DB *gorm.DB

func InitDB(cfg *config.Config) error {
    dsn := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s",
        cfg.Database.Host,
        cfg.Database.Port,
        cfg.Database.User,
        cfg.Database.Password,
        cfg.Database.DBName,
    )

    db, err := gorm.Open(yashandb.Open(dsn), &gorm.Config{})
    if err != nil {
        return err
    }

    DB = db
    return nil
}
```

## Makefile 示例

```makefile
.PHONY: build run test

build:
	go build -o bin/api ./cmd/api

run:
	go run ./cmd/api

test:
	go test -v ./...

migrate:
	go run ./database/migrations/main.go
```

## 相关文档

- [Python 项目布局](python-project-layout.md)
- [部署指南](deployment.md)
- [前端开发指南](frontend-setup.md)
