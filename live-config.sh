# 获取当前时间串
now() {
    if [[ "$*" == 'ts' ]]; then
        echo $(date '+%s')
    else
        echo "@@@@@@@@@@ $(date "+%Y-%m-%d %H:%M:%S") @@@@@@"
    fi
}
alias ts='now ts'

# 后台运行 behind <cmd>
behind() {
    nohup bash -c "$1 '$2' $3 $4" &
}

# 显示当前用户进程树
alias pt="pstree -p $USER"
# 终止某个进程：k <pid>
k() {
    kill -9 $@
}

# 挂载: sdcard sda1 +
# 卸载: sdcard sda1 -
# ps:查看硬盘: df -h ; sudo fdisk -l
sdcard() {
    local dev="${1:-sda1}"
    sudo mkdir -p /mnt/$dev 2>/dev/null
    if [[ "$2" == '-' ]]; then
        sudo mount /dev/$dev /mnt/$dev
    else
        sudo umount /mnt/$dev
    fi
}

# 快捷方式
# (1)更新默认URL：live url 'rtmp://xxx'
# (2)向默认URL推流：live - drama 3
# (3)向指定URL推流：live 'rtmp://xxx' drama -1
live() {
    mkdir -p $HOME/live
    [[ -e $HOME/live/.R ]] && touch $HOME/live/.R
    # 更新推流地址
    if [[ "$1" == 'url' ]]; then
        echo "$2" >$HOME/live/.R
        echo "Remote URL updated!"
        return 0
    elif [[ -z "$1" || "$1" == '?' || "$1" == '-h' || "$1" == '--help' ]]; then
        echo "Usage example："
        echo "  Case#1：update default url"
        echo "      live url 'rtmp://xxx'"
        echo "  Case#2：push 3 videos of the media library named 'drama' to the default url"
        echo "      live - drama 3"
        echo "  Case#3：push all the videos of the media library named 'drama' to the input url on a loop"
        echo "      live 'rtmp://xxx' drama -1"
        return 0
    fi
    # 切换到工作目录后，执行任务
    cd $HOME/live
    behind /live/live-local.sh "$*"
}

# 当前目录的文件批量改名
rename() {
    local path="./"
    local arr=()
    local len=0
    for e in $(ls $path); do
        arr[len]="$e"
        ((len = len + 1))
    done
    local rn
    for ((i = 3; i < len; i++)); do
        rn="${arr[i]:3}"
        rn="$(printf '%02d' $((i + 2))).$rn"
        echo "${arr[i]} => $rn"
        if [[ "$1" == "mv" ]]; then
            mv "${arr[i]}" "$rn"
        fi
    done
}
alias rn=rename
