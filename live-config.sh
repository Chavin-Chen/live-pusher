# 直播主目录
__LIVE_DIR__=${__LIVE_DIR__:-"$HOME/live/0"}
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
    nohup bash -c "__LIVE_DIR__='$__LIVE_DIR__'; $1 '$2' $3 $4" &
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
    if [[ "$2" != '-' ]]; then
        sudo mount /dev/$dev /mnt/$dev
    else
        sudo umount /mnt/$dev
    fi
}

# 快捷方式
live() {
    mkdir -p $__LIVE_DIR__
    [[ ! -e $__LIVE_DIR__/.R ]] && touch $__LIVE_DIR__/.R
    # 更新推流地址
    if [[ "$1" == 'url' || "$1" == '-' || "$1" == 'R' ]]; then
        if [[ -n "$2" ]]; then
            echo "$2" >$__LIVE_DIR__/.R
            echo "Remote URL updated!"
        fi
        cat $__LIVE_DIR__/.R
        return 0
    elif [[ "$1" == 'home' || "$1" == '@' ]]; then
        __LIVE_DIR__="$HOME/live/$2"
        echo "Current:$__LIVE_DIR__"
        return 0
    elif [[ -z "$1" || "$1" == '?' || "$1" == '-h' || "$1" == '--help' ]]; then
        echo "Usage example：(Current=$__LIVE_DIR__)"
        echo "  Case#0：update the home dir of live(path prefix:$HOME/live/)"
        echo "      live home 1"
        echo "  Case#1：update default url"
        echo "      live url 'rtmp://xxx'"
        echo "  Case#2：push 3 videos of the media library named 'drama' to the default url"
        echo "      live - drama 3"
        echo "  Case#3：push all the videos of the media library named 'drama' to the input url on a loop"
        echo "      live 'rtmp://xxx' drama -1"
        return 0
    fi
    # 切换到工作目录后，执行任务
    cd $__LIVE_DIR__
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
