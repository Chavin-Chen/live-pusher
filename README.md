# Live Pusher

Live-pusher, a tool based ffmpeg for pushing stream to live.

> Live-pusher was developed on bash 5.0+, and worked well on ffmpeg 4.3.6-0+deb11u1+rpt2.

## Install

```bash
# prepare
# required bash 5.0+, if not may need install or update(eg. sudo apt install bash)
bash --version
# install ffmpeg
sudo apt install ffmpeg

# clone repo
git clone https://github.com/Chavin-Chen/live-pusher.git 
# grant exec permission
chomd -R 755 /live-pusher/
# add script to init script
echo '[ -s "$HOME/live-pusher/live-config.sh" ] && source /$HOME/live-pusher/live-config.sh' >~/.bashrc
# reload
$ . .bashrc
# show live-pusher version
$ live --version

# upgrade
cd live-pusher/
git fetch --tags
# dev
git checkout -b develop origin/develop
# main
git checkout -b main origin/main
# released version
git checkout -b v1.0 v1.0
```

## Usage

There are 3 steps should done before living:

1. Preparing video(s) for living and config it(s) in `live-local.sh`
2. Create living room on platform and copied url like `rtmp://xxxx`
3. Exec cmd like `live -u 'rtmp://xxx' -m <config-media>'`


```bash
# 1. configration in live-local.sh
main() {
    case $1 in
    # ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ media#1 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    'video'*) # if there is no audio, you can try add 4th param: 'AAC'
        _play 'video' '/mnt/sda1/video/:/mnt/sda2/video/' "$2"    
        ;;
    *)
        echo "Error:no media configuration for $1"
        ;;
    esac
}
# 2. create live room and copied URL; 
# maybe some platform's room address and it's token is split, you should make sure the url contains access token(if the platform needs)

# 3. run pushing cmd: live
live -u 'rtmp://xxx' -m video

# 4. open your living room to check video/audio stream. Good luck to you
```


## Impl

```bash
├── LICENSE
├── README.md
├── editor # some tools for dealing with videos
├── live-config.sh 
│   ├── live       # pusher entry point, use `live -h` to show usage
│   ├── pt         # show process tree for current user
│   ├── k          # `k <pid>` for killing process(eg. k 1234)
│   ├── sdcard     # mount or unmont external storage card
│   ├── rename/rn  # rename files in current dirs
│   ├── behind     # run cmd background
│   └── now        # dump current time/timestamp
└── live-local.sh
    ├── main       # the entry for pushing
    ├── _play      # body for pushing 
    └── _pos_time  # get history push progress
```
