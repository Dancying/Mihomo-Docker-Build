# Mihomo-Docker-Build

一个以 Alpine Linux 为基础镜像的 **“mihomo 内核 + metacubexd 面板”** 轻量化 Docker 容器构建项目。  


## 功能特性

✅ 容器内部打包 mihomo 内核、metacubexd 面板、geoip 数据库，减少启动时的网络等待  
✅ 容器启动时可传入订阅链接下载 mihomo 格式的配置文件，并允许控制配置文件定时更新  
✅ 容器支持传入多个环境变量，例如混合代理端口、允许局域网访问等，并写入到配置文件  

> [!TIP]  
> 本项目使用 Github Actions 自动构建 docker 镜像，镜像目前仅在 [GHCR](https://github.com/Dancying/Mihomo-Docker-Build/pkgs/container/mihomo) 上托管。  


## 容器运行

```sh
docker run -d \
  --name mihomo \
  -p 7890:7890 \
  -p 9090:9090 \
  -v /opt/mihomo/config:/config \
  -e SUB_URL="http://192.168.1.1/sub?token=123456" \
  -e MIXED_PORT=7890 \
  -e ALLOW_LAN="true" \
  -e WEBUI_SECRET="secret123456" \
  ghcr.io/dancying/mihomo:latest
```

> [!IMPORTANT]  
> 请阅读此文档以获取最新的环境变量参数说明和对应使用场景：[docs/env.md](docs/env.md)  


## 开源协议

本项目使用 MIT 开源协议。  

```
MIT License

Copyright (c) 2026 Dancying

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

