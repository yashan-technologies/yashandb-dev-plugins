#!/bin/bash
# YashanDB Docker 部署测试脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common/detect-platform.sh"

OS=$(detect_os)
ARCH=$(detect_arch)

echo "========================================="
echo "YashanDB Docker 部署测试"
echo "========================================="
echo "操作系统: $OS"
echo "架构: $ARCH"
echo ""

# 测试 1: 检查 Docker 安装
test_docker_installed() {
    print_status "测试 1: 检查 Docker 安装..."

    if command_exists docker; then
        DOCKER_VERSION=$(docker --version)
        print_success "Docker 已安装: $DOCKER_VERSION"
        return 0
    else
        print_error "Docker 未安装"
        return 1
    fi
}

# 测试 2: 检查 Docker 守护进程
test_docker_daemon() {
    print_status "测试 2: 检查 Docker 守护进程..."

    if docker ps >/dev/null 2>&1; then
        print_success "Docker 守护进程正在运行"
        return 0
    else
        print_error "Docker 守护进程未运行或无法访问"
        return 1
    fi
}

# 测试 3: 检查平台支持
test_platform_support() {
    print_status "测试 3: 检查平台支持..."

    case "$OS" in
        linux)
            case "$ARCH" in
                x86_64|aarch64)
                    print_success "平台支持: $OS-$ARCH"
                    return 0
                    ;;
                *)
                    print_error "不支持的平台: $OS-$ARCH"
                    return 1
                    ;;
            esac
            ;;
        *)
            print_error "Docker 部署需要 Linux，当前: $OS"
            return 1
            ;;
    esac
}

# 测试 4: 检查磁盘空间
test_disk_space() {
    print_status "测试 4: 检查可用磁盘空间..."

    DISK_SPACE=$(df -BG . 2>/dev/null | tail -1 | awk '{print $4}' | sed 's/G//')
    if [ "$DISK_SPACE" -ge 5 ]; then
        print_success "磁盘空间充足: ${DISK_SPACE}GB"
        return 0
    else
        print_warning "磁盘空间不足: ${DISK_SPACE}GB (建议: 5GB+)"
        return 1
    fi
}

# 测试 5: 检查 Docker Hub 连接（可选）
test_docker_hub() {
    print_status "测试 5: 检查 Docker Hub 连接..."

    if docker pull hello-world >/dev/null 2>&1; then
        print_success "Docker Hub 连接正常"
        return 0
    else
        print_warning "无法连接 Docker Hub，将使用离线导入方式"
        return 1
    fi
}

# 运行所有测试
echo "正在运行测试..."
echo ""

passed=0
failed=0

if test_docker_installed; then ((passed++)); else ((failed++)); fi
echo ""

if test_docker_daemon; then ((passed++)); else ((failed++)); fi
echo ""

if test_platform_support; then ((passed++)); else ((failed++)); fi
echo ""

if test_disk_space; then ((passed++)); else ((failed++)); fi
echo ""

# Docker Hub 连接测试（可选，不计入失败）
test_docker_hub
echo ""

echo "========================================="
echo "测试摘要"
echo "========================================="
echo "passed: $passed"
echo "failed: $failed"
echo ""

if [ $failed -eq 0 ]; then
    print_success "所有测试通过！"
    echo ""
    echo "下一步：执行部署脚本"
    echo "  bash scripts/yashandb-docker/deploy-yashandb.sh"
    exit 0
else
    print_warning "部分测试失败"
    exit 1
fi