# =============================================================================================
# ************************************** 用户配置媒体库 *****************************************
# =============================================================================================
# Usage: main drama -1
main() {
    case $1 in # 媒体库
    # ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ 媒体库1 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    'dra'*)
        _play 'drama' "/mnt/sda1/drama/:/mnt/sda2/drama/" "$2" "AAC"
        ;;
    # ------------------------------ END -------------------------------
    *)
        echo "Error:no media configuration for $1"
        ;;
    esac
}

# =============================================================================================
# **************************************** Private ********************************************
# =============================================================================================
# 存档当前进度（自动读取当前推流时间点）: _pos_time $FUNCNAME $pos
_pos_time() {
    local posFile="$__LIVE_DIR__/.local/$1"
    local line=$(cat $__LIVE_DIR__/.local/ffmpeg.out | grep '^frame=.*time=.*speed=' | tail -n 1)
    local time=$(echo $line | awk -F 'time=' '{print $2}' | awk -F 'bitrate=' '{print $1}')
    local hour="$(echo $time | awk -F ':' '{print $1}' | sed -r 's/0*([0-9])/\1/')"
    local min="$(echo $time | awk -F ':' '{print $2}' | sed -r 's/0*([0-9])/\1/')"
    local sec="$(echo $time | awk -F ':' '{print $3}' | awk -F '.' '{print $1}' | sed -r 's/0*([0-9])/\1/')"
    hour=$((hour * 3600))
    min=$((min * 60))
    local offset=$((hour + min + sec - 10))
    ((offset < 0)) && ((offset = 0))
    echo -e "$2\n$offset" >$posFile
}

# 开始推流 _play {posName} {paths} {cnt} 'AAC'
_play() {
    # 检查存档文件
    local file="$1"
    [[ ! -e $__LIVE_DIR__/.local/$file ]] && touch $__LIVE_DIR__/.local/$file
    # 采集媒体库目录文件列表
    local paths=()
    readarray -d ':' -t paths <<<$2
    local arr=()
    local len=0
    for path in ${paths[@]}; do
        for e in $(ls "$path"*); do
            arr[len]=$e
            ((len = len + 1))
        done
    done
    # 读取存档分集与偏移
    local pos
    local offset
    {
        read pos
        pos=${pos:-0}
        read offset
        offset=${offset:-0}
    } <$__LIVE_DIR__/.local/$file
    # 解析累计推流集数（默认播完就停播）
    local n=${3:-"$len"}
    ((n == -1)) && n="$len"
    local cnt=0
    echo "plan to push $file($2) $n files"
    # 解析音频编码参数
    local encode="-c copy -max_muxing_queue_size 1024"
    if [[ "$*"==*'AAC'* ]]; then
        encode="-c:a aac -c:v copy -max_muxing_queue_size 1024"
    fi
    # 检查推流地址
    local url
    if [[ -z "$__URL__" || "$__URL__" == '-'* ]]; then # 取默认地址
        {
            read url
            url=${url:-''}
        } <$__LIVE_DIR__/.R
    else
        url="$__URL__"
    fi
    if [[ -z "$url" ]]; then
        echo 'ERROR: remote url is empty!'
        return -1
    fi
    local code
    local errs
    local retry=0
    # 循环推流，直到分集数
    for ((i = pos; i < len && (cnt < n || n <= 0); )); do
        echo "start pushing $pos: ${arr[i]} offset=$offset"
        ffmpeg -re -ss $offset -i ${arr[i]} $encode -f flv -flvflags no_duration_filesize -hide_banner \
            $url >$__LIVE_DIR__/.local/ffmpeg.out 2>&1
        # 若输出中的ERROR小于某个阈值则认为是推流失败（推流断开通常是末尾有一个Error）
        code=$?
        errs=$(grep -i -c "Error" $__LIVE_DIR__/.local/ffmpeg.out)
        if ((code > 0 && code < 128 || errs > 0 && errs < 10)); then
            echo "$file breaked at: $pos (code=$code, err=$errs)"
            _pos_time $file $((i))
            if ((retry >= 3)); then
                break
            else
                retry++
                sleep 3
                continue
            fi
        fi
        retry=0
        offset=0 # 清空首集偏移
        echo "pushed $pos: ${arr[i]}"
        ((i = (i + 1) % len))
        ((cnt = cnt + 1))
        pos=$((i))
        echo "$pos" >$__LIVE_DIR__/.local/$file
    done
}

# 加载工具库
source /live/live-config.sh
# 直播主目录
__LIVE_DIR__=${__LIVE_DIR__:-"$HOME/live/0"}
# 推流地址
__URL__=${__URL__:-''}
media=''
num=0
while getopts 'd:u:m:n:' args; do
    case ${args} in
    d)
        __LIVE_DIR__="$OPTARG"
        ;;
    u)
        __URL__="$OPTARG"
        ;;
    m)
        media="$OPTARG"
        ;;
    n)
        num=$OPTARG
        ;;
    *)
        echo "ERROR INPUT!!!"
        return 1
        ;;
    esac
done
# 日志目录
mkdir -p $__LIVE_DIR__/.local
# 开始推流
main $media $num
