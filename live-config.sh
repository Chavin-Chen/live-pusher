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
    nohup bash -c "$*" &
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

# 快捷方式
live() {
    mkdir -p $__LIVE_DIR__
    [[ ! -e $__LIVE_DIR__/.R ]] && touch $__LIVE_DIR__/.R

    local dir="$__LIVE_DIR__"
    local url
    {
        read url
    } <$dir/.R
    local media=''
    local num='-1'
    local doc=0
    # parse options
    local args=$(getopt -o d:,u:,m:,n:,h -l dir:,url:,media:,num:,help -a -- $*)
    eval set -- $args
    if [[ "$args" == ' --' ]]; then
        doc=1
    else
        while true; do
            case "$1" in
            -d | --dir)
                dir="$HOME/live/$2"
                [[ ! -e $dir ]] && mkdir -p $dir
                [[ ! -e $dir/.R ]] && touch $dir/.R
                if [[ -z "$url" ]]; then
                    {
                        read url
                    } <$dir/.R
                fi
                shift 2
                ;;
            -u | --url)
                url="$2"
                shift 2
                ;;
            -m | --media)
                media="$2"
                shift 2
                ;;
            -n | --num)
                num="$2"
                shift 2
                ;;
            -h | --help)
                doc=1
                shift
                ;;
            --)
                [ -z "$media" ] && [ -n "$2" ] && media="$2"
                shift
                break
                ;;
            *)
                doc=1
                shift
                ;;
            esac
        done
    fi
    [[ -n "$dir" ]] && __LIVE_DIR__="$dir"
    [[ -n "$url" ]] && echo "$url" >$dir/.R
    [[ -z "$media" ]] && doc=1
    if ((doc == 1)); then
    cd $dir
        cat <<-END
Current version: 1.0
 dir=$dir
 url=$url

Usage:
 live --media=drama --url=rtmp://xxxx
    start to push media library named drama to target url

Options:
 -d, --dir <dir-number>             set the log dir, auto prefixed '$HOME/live/'
 -u, --url <rtmp-url>               set the target url to push 
 -m, --media <media-lib>            set the media library configured in live-local.sh
 -n, --num <num-of-videos-to-push>  set the number of videos preparing to push
 -h, --help                         show help
END
        return 0
    fi
    # 切换到工作目录后，执行任务
    cd $dir
    behind /live/live-local.sh -d $dir -u "'$url'" -m $media -n $num
}
