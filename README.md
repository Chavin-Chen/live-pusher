# Live Pusher

Live-pusher, a tool based ffmpeg for pushing stream to live.

> Live-pusher was developed on bash 5.0+, and worked well on ffmpeg 4.3.6-0+deb11u1+rpt2.

## Install

```bash
# prepare ffmpeg 
sudo apt install ffmpeg

# clone repo
git clone XXX 
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
3. Exec cmd like `live -u rtmp://xxx -m <config-media>`


```bash
# 1. configration in live-local.sh


# 3. 
```


## Impl


