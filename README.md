# Mihomo-Docker-Build

一个基于 Alpine Linux 的轻量化 Mihomo (Clash Meta) 容器化构建与部署方案。支持自动化依赖预处理、多环境变量动态配置以及 GitHub Actions 自动化流水线。

---

## 🚀 特性

* **高效流水线构建**：解耦依赖准备与镜像构建流程，支持通过本地或 CI/CD 预处理脚本，实现前置核心文件的秒级打包与高效分发。
* **参数动态化注入**：全面支持容器环境变量覆盖，无需手动修改配置文件，即可在容器启动或运行时对网络核心策略进行动态调整。
* **多重请求头订阅**：支持多种 User-Agent 请求头组合轮询与动态回退，内置失败容错、历史归档及成功缓存机制，大幅提升成功率。
* **高可用守护进程**：内置防崩溃熔断保障与轻量级进程守护机制，在配置定时更新或核心内核异常退出时，保障引擎秒级无缝重载。
* **全平台容器兼容**：采用规范标准的基础镜像路径声明，全面抹平底层工具链差异，完美兼容 Docker 和 Podman 等主流运行环境。

---

## 🛠️ 项目结构

```text
├── .github/workflows/
│   └── docker-build.yml   # GitHub Actions 自动化构建工作流
├── app/
│   ├── config_update.sh   # 订阅更新与参数修改核心脚本
│   ├── cron_setup.sh      # 订阅更新定时任务监控脚本
│   ├── dir_init.sh        # 容器目录初始化脚本
│   └── entrypoint.sh      # 容器主入口守护脚本
├── Dockerfile             # 容器镜像构建文件
└── pre_build.sh           # 容器构建前置依赖下载脚本
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
  -e SUB_URL="http://192.168.1.1/sub?token=123456" \
  -e UPDATE_INTERVAL=12 \
  -e MIXED_PORT=7890 \
  -e ALLOW_LAN="true" \
  -e IPV6="false" \
  -e MIHOMO_MODE="Rule" \
  -e BIND_ADDRESS="0.0.0.0" \
  -e AUTHENTICATION="username:password123" \
  -e WEBUI_LISTEN_ADDR="0.0.0.0:9090" \
  -e WEBUI_SECRET="secret123456" \
  ghcr.io/dancying/mihomo:latest
```

---

## 📌 环境变量说明

所有环境变量均为**可选**参数。若未配置对应的环境变量，容器将不会对配置文件中的关联参数进行覆盖重写，仅使用订阅节点文件中的默认值。

| 环境变量 | 默认值 | 描述 |
| :--- | :--- | :--- |
| `SUB_URL` | 无 | 订阅链接（例如：`http://192.168.1.1/sub?token=123456`）。 |
| `UPDATE_INTERVAL` | 无 | 订阅配置文件定时更新周期（单位：小时）。 |
| `MIXED_PORT` | 无 | 混合代理端口（例如：`7890`），修改后自动置顶到配置文件首行。 |
| `ALLOW_LAN` | 无 | 是否允许局域网外部设备访问（可选：`true` / `false`）。 |
| `IPV6` | 无 | 是否开启 IPv6 支持（可选：`true` / `false`）。 |
| `MIHOMO_MODE` | 无 | 运行模式（可选：`Rule`, `Global`, `Direct`）。 |
| `BIND_ADDRESS` | 无 | 局域网监听地址（通常配合 `ALLOW_LAN=true` 设置为 `0.0.0.0`）。 |
| `AUTHENTICATION` | 无 | 代理身份验证。多账号需要用逗号分隔（例如：`"user1:pwd1,user2:pwd2"`）。 |
| `WEBUI_LISTEN_ADDR`| `0.0.0.0:9090` | Web UI 控制面板的外部监听地址与端口。 |
| `WEBUI_SECRET` | 随机生成 | Web UI 控制面板的访问密钥。默认随机生成，随机生成的密钥需查看日志获取。 |

---

## 📂 挂载卷说明

* `/config`：核心工作目录。容器启动后会自动在此目录下生成配置文件、控制面板（`WEBUI` 子目录）以及更新历史记录（`history` 子目录）。
```txt
/config
├── config.yaml                 # 当前生效的配置文件
├── WEBUI/                      # Metacubexd 前端控制面板
└── history/                    # 历史配置备份目录
    ├── config_*.yaml           # 成功更新前的历史备份
    └── config_*_failed_*.yaml  # 下载失败的损坏配置归档（用于排查）
```
