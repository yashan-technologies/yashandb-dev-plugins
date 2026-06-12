#!/bin/bash
# YashanDB Python 驱动测试脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common/detect-platform.sh"

echo "========================================="
echo "YashanDB Python 驱动测试"
echo "========================================="
echo ""

# 测试 1: 检查 Python 安装
test_python_installed() {
    print_status "测试 1: 检查 Python 安装..."

    if command_exists python3; then
        PYTHON_VERSION=$(python3 --version)
        print_success "Python 已安装: $PYTHON_VERSION"
        return 0
    elif command_exists python; then
        PYTHON_VERSION=$(python --version)
        print_success "Python 已安装: $PYTHON_VERSION"
        return 0
    else
        print_error "Python 未安装"
        return 1
    fi
}

# 测试 2: 检查 Python 驱动
test_python_driver() {
    print_status "测试 2: 检查 Python 驱动..."

    PYTHON_CMD="python3"
    if ! command_exists python3; then
        PYTHON_CMD="python"
    fi

    if $PYTHON_CMD -c "import yaspy" 2>/dev/null; then
        YASPY_VERSION=$($PYTHON_CMD -m pip show yaspy 2>/dev/null | grep "^Version:" | awk '{print $2}')
        if [ -n "$YASPY_VERSION" ]; then
            print_success "yaspy 模块已安装: $YASPY_VERSION"
        else
            print_success "yaspy 模块已安装"
        fi
        return 0
    elif $PYTHON_CMD -c "import yasdb" 2>/dev/null; then
        YASDB_VERSION=$($PYTHON_CMD -m pip show yasdb 2>/dev/null | grep "^Version:" | awk '{print $2}')
        if [ -n "$YASDB_VERSION" ]; then
            print_success "yasdb 模块已安装: $YASDB_VERSION"
        else
            print_success "yasdb 模块已安装"
        fi
        return 0
    else
        print_warning "Python 驱动 (yasdb/yaspy) 未安装"
        return 1
    fi
}

# 测试 3: 检查 C 驱动
test_c_driver() {
    print_status "测试 3: 检查 C 驱动依赖..."

    case "$(detect_os)" in
        linux|macos)
            if ldconfig -p 2>/dev/null | grep -q "libyascli"; then
                print_success "找到 C 驱动库"
                return 0
            else
                print_warning "未找到 C 驱动库"
                return 1
            fi
            ;;
        windows)
            if where.exe yascli.dll 2>/dev/null | grep -q "yascli"; then
                print_success "找到 C 驱动库"
                return 0
            else
                print_warning "未找到 C 驱动库"
                return 1
            fi
            ;;
    esac
}

# 运行所有测试
echo "正在运行测试..."
echo ""

passed=0
failed=0

if test_python_installed; then ((passed++)); else ((failed++)); fi
echo ""

if test_python_driver; then ((passed++)); else ((failed++)); fi
echo ""

if test_c_driver; then ((passed++)); else ((failed++)); fi
echo ""

echo "========================================="
echo "测试摘要"
echo "========================================="
echo "passed: $passed"
echo "failed: $failed"
echo ""

if [ $failed -eq 0 ]; then
    print_success "所有测试通过！"
    exit 0
else
    print_warning "部分测试失败"
    exit 1
fi