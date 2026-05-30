# Mihomo-Docker-Build

一个基于 Alpine Linux 的轻量化 Mihomo (Clash Meta) 容器化构建与部署方案。支持自动化依赖预处理、多环境变量动态配置以及 GitHub Actions 自动化流水线。

---

## 🚀 特性

* **极速构建**：解耦依赖准备与镜像构建，通过本地或 CI/CD 预处理脚本秒级完成前置打包。
* **动态配置**：支持通过 Docker 环境变量动态修改 `mixed-port`、`allow-lan`、`mode` 及 `ipv6` 等核心参数。
* **双 UA 智能订阅**：自动尝试 `Clash` 和 `Mihomo` 的 User-Agent 获取订阅，并具备失败回滚与历史归档机制。
* **秒级复活**：内置轻量级守护进程，在配置更新或核心异常退出时实现秒级无缝重载。
* **完美适配 Podman**：Dockerfile 基础镜像采用完整路径，全面兼容 Docker 及 Podman 构建环境。

---

## 🛠️ 项目结构

```text
├── .github/workflows/
│   └── docker-build.yml   # GitHub Actions 自动化构建工作流
├── app/
│   ├── config_update.sh   # 订阅更新与参数修改核心脚本
│   ├── cron_setup.sh      # 定时任务配置脚本
│   ├── dir_init.sh        # 容器目录初始化脚本
│   └── entrypoint.sh      # 容器主入口守护脚本
├── Dockerfile             # 容器镜像构建文件
└── pre_build.sh           # 构建前置依赖下载与数据装配脚本
```

---

## 📦 构建与部署

### 1. 本地构建流程

在构建镜像之前，必须先运行预处理脚本以准备二进制程序和数据：

```bash
# 执行前置脚本（下载 Mihomo 核心、规则数据、Web UI）
bash pre_build.sh

# 使用 Docker 构建镜像
docker build -t mihomo:latest .
```

### 2. 自动化构建 (GitHub Actions)

项目已内置工作流。只需将代码推送到 `main` 分支，GitHub Actions 便会自动触发构建并将镜像托管至 GitHub Container Registry (`ghcr.io`)。

---

## ⚙️ 容器运行

```bash
docker run -d \
  --name mihomo \
  --restart always \
  -p 7890:7890 \
  -p 9090:9090 \
  -v /opt/mihomo/config:/config \
  -e SUB_URL="https://example.com/sub?token=123" \
  -e UPDATE_INTERVAL=6 \
  -e ALLOW_LAN="true" \
  -e MIXED_PORT=7890 \
  -e MIHOMO_MODE="Rule" \
  -e IPV6="false" \
  -e WEBUI_LISTEN_ADDR="0.0.0.0:9090" \
  -e WEBUI_SECRET="secret123456" \
  ghcr.io/dancying/mihomo:latest
```

---

## 📌 环境变量说明

所有环境变量均为**可选**参数。若未配置对应的环境变量，系统将不会对配置文件中的关联参数进行强制重写，而是保持订阅节点文件中的原有默认配置或系统内置默认值。

| 环境变量 | 默认值 | 描述 |
| :--- | :--- | :--- |
| `SUB_URL` | 无 | 你的订阅/节点链接（例如：https://example.com/sub ）。 |
| `UPDATE_INTERVAL` | 无 | 订阅自动更新间隔时间（单位：小时，例如：`6`）。若不配置则不会启用自动定时更新功能。 |
| `ALLOW_LAN` | 无 | 是否允许局域网外部访问（可选值：`true` 或 `false`）。 |
| `BIND_ADDRESS` | 绑定地址 | 配合局域网使用，需设置为 0.0.0.0 |
| `MIXED_PORT` | 无 | 动态修改或置顶混合代理端口（例如：`7890`）。 |
| `MIHOMO_MODE` | 无 | 动态修改运行模式（可选值：`Rule`, `Global`, `Direct`）。 |
| `IPV6` | 无 | 动态修改 IPv6 总开关（可选值：`true` 或 `false`）。 |
| `WEBUI_LISTEN_ADDR`| `0.0.0.0:9090` | Web UI 控制面板的监听地址与端口。 |
| `WEBUI_SECRET` | 随机生成 | Web UI 控制面板的外部控制访问密钥（密码）。若不指定则在每次容器启动时随机生成，可通过查看容器启动日志获取。 |

---

## 📂 挂载卷说明

* `/config`：核心工作目录。容器启动后会自动在此目录下生成配置文件、控制面板（`WEBUI` 子目录）以及更新历史记录（`history` 子目录）。
```txt
/config
├── config.yaml          # 当前生效的配置文件
├── WEBUI/               # Metacubexd 前端控制面板
└── history/             # 历史配置备份目录
    ├── config_*.yaml    # 成功更新前的历史备份
    └── config_*_failed_*.yaml # 下载失败的损坏配置归档（用于排查）
```
