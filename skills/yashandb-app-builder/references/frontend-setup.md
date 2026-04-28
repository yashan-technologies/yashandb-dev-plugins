# 前端开发指南

## 概述

本文档介绍基于 Vue3 的前端开发流程，包括项目初始化、页面开发和前后端联调。

## 技术栈

- **框架**：Vue 3
- **构建工具**：Vite
- **HTTP 客户端**：Axios
- **路由**：Vue Router

## 项目结构

```
frontend/
├── src/
│   ├── views/           # 页面视图
│   │   └── HomeView.vue
│   ├── components/     # 公共组件
│   │   └── Header.vue
│   ├── api/            # API 调用
│   │   └── index.js
│   ├── router/         # 路由配置
│   │   └── index.js
│   ├── App.vue
│   └── main.js
├── public/
├── index.html
├── package.json
└── vite.config.js
```

## 快速开始

### 初始化项目

```bash
# 创建 Vue3 项目
npm create vite@latest frontend -- --template vue

# 进入项目目录
cd frontend

# 安装依赖
npm install

# 安装额外依赖
npm install axios vue-router
```

### 启动开发服务器

```bash
npm run dev
```

默认访问地址：http://localhost:5173

## 页面开发示例

### 1. 创建 API 调用模块

```javascript
// src/api/index.js
import axios from 'axios';

const apiClient = axios.create({
    baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000',
    timeout: 10000,
});

export default {
    getUsers() {
        return apiClient.get('/users');
    },
    createUser(user) {
        return apiClient.post('/users', user);
    },
    deleteUser(id) {
        return apiClient.delete(`/users/${id}`);
    }
};
```

### 2. 创建页面视图

```vue
<!-- src/views/HomeView.vue -->
<template>
  <div class="home">
    <h1>用户列表</h1>
    <button @click="loadUsers">刷新</button>
    <ul>
      <li v-for="user in users" :key="user.id">
        {{ user.name }} - {{ user.email }}
        <button @click="deleteUser(user.id)">删除</button>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../api';

const users = ref([]);

const loadUsers = async () => {
  try {
    const response = await api.getUsers();
    users.value = response.data;
  } catch (error) {
    console.error('Failed to load users:', error);
  }
};

const deleteUser = async (id) => {
  try {
    await api.deleteUser(id);
    await loadUsers();
  } catch (error) {
    console.error('Failed to delete user:', error);
  }
};

onMounted(() => {
  loadUsers();
});
</script>
```

### 3. 配置路由

```javascript
// src/router/index.js
import { createRouter, createWebHistory } from 'vue-router';
import HomeView from '../views/HomeView.vue';

const routes = [
  {
    path: '/',
    name: 'Home',
    component: HomeView
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
```

### 4. 配置环境变量

```bash
# .env
VITE_API_BASE_URL=http://localhost:8000
```

## 前后端联调

### 1. 解决跨域问题

在 Vite 配置中添加代理：

```javascript
// vite.config.js
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [vue()],
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  }
});
```

### 2. 测试联调

```bash
# 启动后端服务
# 启动前端服务
npm run dev

# 打开浏览器访问 http://localhost:5173
# 测试 CRUD 功能
```

## 常见问题

### 1. CORS 跨域错误

后端需要配置 CORS：

```python
# Python/FastAPI
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 2. API 请求失败

检查：
- 后端服务是否启动
- API 地址是否正确
- 网络连接是否正常

## 相关文档

- [Golang 项目布局](golang-project-layout.md)
- [Python 项目布局](python-project-layout.md)
- [部署指南](deployment.md)
