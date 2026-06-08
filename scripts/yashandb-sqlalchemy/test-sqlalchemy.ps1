# YashanDB SQLAlchemy 测试脚本 (PowerShell)

$ErrorActionPreference = "Continue"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$SCRIPT_DIR\..\common\detect-platform.ps1"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "YashanDB SQLAlchemy 测试" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

function Get-PythonCmd {
    if (Test-Command python3) { return "python3" }
    if (Test-Command python) { return "python" }
    return $null
}

# 执行 python -c 并判断成功与否（兼容 PowerShell 5.1）
function Test-PythonExpr {
    param(
        [string]$PythonCmd,
        [string]$Expr
    )
    $null = & $PythonCmd -c $Expr 2>$null
    if ($null -ne $LASTEXITCODE) {
        return ($LASTEXITCODE -eq 0)
    }
    return $?
}

# 获取 pip 包版本
function Get-PipPackageVersion {
    param(
        [string]$PythonCmd,
        [string]$PackageName
    )
    $line = & $PythonCmd -m pip show $PackageName 2>$null | Select-String "^Version:"
    if ($line) {
        return $line.ToString().Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)[1]
    }
    return $null
}

# 测试 1: 检查 Python 安装
function Test-PythonInstalled {
    Write-Status "测试 1: 检查 Python 安装..."

    if (Test-Command python3) {
        $version = python3 --version
        Write-Success "Python 已安装: $version"
        return $true
    } elseif (Test-Command python) {
        $version = python --version
        Write-Success "Python 已安装: $version"
        return $true
    } else {
        Write-ErrorMsg "Python 未安装"
        return $false
    }
}

# 测试 2: 检查 SQLAlchemy 安装（建议 2.0.50，2.0.x 均可）
function Test-SQLAlchemyInstalled {
    Write-Status "测试 2: 检查 SQLAlchemy 安装..."

    $pythonCmd = Get-PythonCmd
    if (-not $pythonCmd) {
        Write-ErrorMsg "SQLAlchemy 未安装"
        return $false
    }

    $version = & $pythonCmd -c "import sqlalchemy; print(sqlalchemy.__version__)" 2>$null
    if ($version) {
        if ($version -like "2.0*") {
            Write-Success "SQLAlchemy 已安装: $version"
            return $true
        } else {
            Write-WarningMsg "SQLAlchemy 版本: $version (建议采用 2.0.50)"
            return $false
        }
    } else {
        Write-ErrorMsg "SQLAlchemy 未安装"
        return $false
    }
}

# 测试 3: 检查 yaspy 驱动（推荐 1.2.1）
function Test-YaspyDriver {
    Write-Status "测试 3: 检查 yaspy 驱动..."

    $pythonCmd = Get-PythonCmd
    if (-not $pythonCmd) {
        Write-ErrorMsg "yaspy 模块未安装"
        return $false
    }

    if (Test-PythonExpr -PythonCmd $pythonCmd -Expr "import yaspy") {
        $version = Get-PipPackageVersion -PythonCmd $pythonCmd -PackageName "yaspy"
        if ($version) {
            Write-Success "yaspy 模块已安装: $version"
        } else {
            Write-Success "yaspy 模块已安装"
        }
        return $true
    } else {
        Write-ErrorMsg "yaspy 模块未安装"
        return $false
    }
}

# 测试 4: 检查 yashandb-sqlalchemy 方言（推荐 2.0.0）
function Test-YashandbSqlalchemy {
    Write-Status "测试 4: 检查 yashandb-sqlalchemy 方言..."

    $pythonCmd = Get-PythonCmd
    if (-not $pythonCmd) {
        Write-ErrorMsg "yashandb-sqlalchemy 模块未安装"
        return $false
    }

    if (Test-PythonExpr -PythonCmd $pythonCmd -Expr "import yashandb_sqlalchemy") {
        $version = Get-PipPackageVersion -PythonCmd $pythonCmd -PackageName "yashandb-sqlalchemy"
        if ($version) {
            Write-Success "yashandb-sqlalchemy 模块已安装: $version"
        } else {
            Write-Success "yashandb-sqlalchemy 模块已安装"
        }
        return $true
    }

    $pipVersion = Get-PipPackageVersion -PythonCmd $pythonCmd -PackageName "yashandb-sqlalchemy"
    if ($pipVersion) {
        Write-ErrorMsg "yashandb-sqlalchemy 已安装 ($pipVersion) 但无法导入，请升级: pip install yashandb-sqlalchemy==2.0.0"
    } else {
        Write-ErrorMsg "yashandb-sqlalchemy 模块未安装"
    }
    return $false
}

# 测试 5: 检查 C 驱动依赖
function Test-CDriver {
    Write-Status "测试 5: 检查 C 驱动依赖..."

    $yascliPath = Get-Command yascli.dll -ErrorAction SilentlyContinue
    if ($yascliPath) {
        Write-Success "找到 C 驱动库 (yascli.dll)"
        return $true
    } else {
        Write-WarningMsg "未找到 C 驱动库 (yascli.dll)"
        return $false
    }
}

# 测试 6: 检查 yashandb-sqlalchemy 方言注册
function Test-DialectRegistered {
    Write-Status "测试 6: 检查 yashandb 方言注册..."

    $pythonCmd = Get-PythonCmd
    if (-not $pythonCmd) {
        Write-WarningMsg "yashandb 方言可能未正确注册"
        return $false
    }

    $registryResult = & $pythonCmd -c "from sqlalchemy.dialects import registry; print(registry.contains('yashandb', 'yaspy'))" 2>$null
    if ($registryResult -match "True") {
        Write-Success "yashandb 方言已注册"
        return $true
    }

    if (Test-PythonExpr -PythonCmd $pythonCmd -Expr "from yashandb_sqlalchemy import yaspy") {
        Write-Success "yashandb 方言可正常导入"
        return $true
    } else {
        Write-WarningMsg "yashandb 方言可能未正确注册"
        return $false
    }
}

# 运行所有测试
Write-Host "正在运行测试..."
Write-Host ""

$passed = 0
$failed = 0

if (Test-PythonInstalled) { $passed++ } else { $failed++ }
Write-Host ""

if (Test-SQLAlchemyInstalled) { $passed++ } else { $failed++ }
Write-Host ""

if (Test-YaspyDriver) { $passed++ } else { $failed++ }
Write-Host ""

if (Test-YashandbSqlalchemy) { $passed++ } else { $failed++ }
Write-Host ""

if (Test-CDriver) { $passed++ } else { $failed++ }
Write-Host ""

if (Test-DialectRegistered) { $passed++ } else { $failed++ }
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "测试摘要" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "passed: $passed"
Write-Host "failed: $failed"
Write-Host ""

if ($failed -eq 0) {
    Write-Success "所有测试通过！"
    Write-Host ""
    Write-Host "YashanDB SQLAlchemy 环境已就绪，可以使用以下连接字符串：" -ForegroundColor Cyan
    Write-Host "  yashandb+yaspy://用户名:密码@主机:端口/数据库名" -ForegroundColor White
    exit 0
} else {
    Write-WarningMsg "部分测试失败，请检查上述错误"
    exit 1
}
