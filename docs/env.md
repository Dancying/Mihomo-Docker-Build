# 环境变量

本项目中的所有环境变量都是可选变量，只有少部分变量具有默认值。  


## SUB_URL

订阅链接地址，该变量值需要以 `https` 开头，例如 `SUB_URL="https://192.168.1.10/sub?token=123456"` 。  

绝大多数机场都能使用 **通用订阅链接地址** 获取 mihomo 格式的配置文件。  


## USE_PROXYSCOTCH

是否启用 Hoppscotch 服务器下载订阅配置，默认情况下使用直连方式下载订阅配置。  

部分机场 **国内网络无法下载订阅配置** ，此情况可以添加 `USE_PROXYSCOTCH="true"` 来正常下载。  

Hoppscotch 是一个第三方服务器，该服务器可能会留存网络请求记录，故默认不启用此下载方式。  

Hoppscotch 网页服务： https://hoppscotch.io  


## UPDATE_INTERVAL

订阅配置定时更新间隔时间（单位小时），例如 `UPDATE_INTERVAL=24` 表示每 24 小时更新一次订阅配置。  

部分机场 **节点需要定时更新** 内容，否则可能无法正常使用，此情况可以添加该变量来控制定时更新间隔。  


## WEBUI_LISTEN_ADDR

metacubexd 面板的监听地址，默认值为 `WEBUI_LISTEN_ADDR="0.0.0.0:9090"` 。  

如果容器设置了开机自启则 **不建议修改** ，否则概率出现 Linux 系统重启后无法访问 metacubexd 面板的情况。  


## WEBUI_SECRET

访问 metacubexd 面板所需要的密码，默认随机生成，随机生成的密码需要查看容器日志获取。  

基于安全性考虑， **本项目中禁止设置 `WEBUI_SECRET` 为空** ，该变量为空时则会使用随机生成的密码。  


## WEBUI_OVERWRITE

是否使用容器内已打包的 metacubexd 面板版本。  

metacubexd 面板中允许手动更新面板版本，若设置 `WEBUI_OVERWRITE="false"` 可以防止新版本被覆盖。  

多数情况下容器内的 metacubexd 面板版本会落后于最新版几个小版本，若不在意则不建议调整该变量。  


### MIXED_PORT

混合代理端口， **建议显式声明** ，例如 `MIXED_PORT=7890` 。  

参数说明：https://wiki.metacubex.one/config/inbound/port/#_3  


## ALLOW_LAN

是否允许局域网设备访问， **建议显式声明** ，例如 `ALLOW_LAN="true"` 。  

参数说明：https://wiki.metacubex.one/config/general/#_2  


## IPV6

是否接受 IPV6 流量，若需要则设置 `IPV6="true"` 。  

参数说明：https://wiki.metacubex.one/config/general/#ipv6  


## MIHOMO_MODE

内核运行模式， **建议显式声明** ，例如 `MIHOMO_MODE="rule"` 。  

参数说明：https://wiki.metacubex.one/config/general/#_4  


## BIND_ADDRESS

控制可以访问的 IP 地址设备，一般配合 `ALLOW_LAN="true"` 使用。  

例如 `BIND_ADDRESS="*"` 允许所有设备，而 `BIND_ADDRESS="192.168.1.10"` 仅允许特定设备。  

参数说明：https://wiki.metacubex.one/config/general/#_2  


## AUTHENTICATION

设置用户身份验证，一般配合 `ALLOW_LAN="true"` 使用。  

多个用户使用逗号分隔，例如 `AUTHENTICATION="user1:pwd1,user2:pwd2"` 。  

注意部分软件无法进行代理的用户身份验证，如果只在局域网内使用代理则不建议使用该变量。  

参数说明：https://wiki.metacubex.one/config/general/#_3  


## SKIP_AUTH_PREFIXES

允许跳过身份验证的 IP 地址，一般配合 `AUTHENTICATION` 变量使用。  

多个 IP 网段使用逗号分隔，例如 `SKIP_AUTH_PREFIXES="127.0.0.1/8,::1/128"` 。  

参数说明：https://wiki.metacubex.one/config/general/#_3  

