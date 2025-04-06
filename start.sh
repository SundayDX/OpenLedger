#!/bin/bash

# 检查 Docker 镜像是否存在
if ! docker images openledger -q | grep -q .; then
    echo "未找到 openledger 镜像，开始构建..."
    docker build -t openledger .
else
    echo "找到现有 openledger 镜像，跳过构建步骤"
fi

# 检查 accounts.json 是否存在
if [ ! -f "accounts.json" ]; then
    echo "未找到 accounts.json 文件，开始创建..."
    
    # 创建或清空 accounts.json 文件
    echo "[]" > accounts.json
    
    # 提示用户输入账户数量并验证
    while true; do
        read -p "请输入需要配置的账户数量（1-1000）: " account_count
        if [[ "$account_count" =~ ^[0-9]+$ ]] && [ "$account_count" -ge 1 ] && [ "$account_count" -le 1000 ]; then
            break
        else
            echo "输入无效，请输入一个 1 到 1000 之间的正整数。"
        fi
    done
    
    # 使用临时数组收集账户信息
    accounts_json="[]"
    for ((i=1; i<=account_count; i++)); do
        echo "正在配置第 $i 个账户:"
        read -p "请输入 Address: " address
        read -p "请输入 Access_Token: " access_token
        
        # 检查输入是否为空
        if [ -z "$address" ] || [ -z "$access_token" ]; then
            echo "Address 或 Access_Token 不能为空，请重新输入。"
            ((i--))
            continue
        fi
        
        # 将账户信息添加到临时 JSON
        accounts_json=$(jq --arg addr "$address" --arg token "$access_token" \
           '. += [{"Address": $addr, "Access_Token": $token}]' <<< "$accounts_json")
    done
    
    # 一次性写入 accounts.json
    echo "$accounts_json" > accounts.json
    if [ $? -ne 0 ]; then
        echo "写入 accounts.json 失败，请检查权限或磁盘空间。"
        exit 1
    fi
    
    echo "账户信息已保存到 accounts.json"
    echo "当前 accounts.json 内容如下:"
    cat accounts.json
fi

docker run -d -v $(pwd)/accounts.json:/app/accounts.json -v $(pwd)/proxy.txt:/app/proxy.txt openledger