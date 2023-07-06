# soundclown
## simple soundcloud music downloader

### usage
```
$ soundclown -h
soundclown v1.0

usage: soundclown <url/id> [file]
    url - soundcloud url or song id
    file - output file (format is opus)

if file isnt specified then song info will be
displayed instead of the song being downloaded
```

### features
- downloads music in opus format
- automagically embeds author, track title, and album art
- can also just display author track title and album art url without downloading music

### deps
- bash
- yt-dlp
- ffmpeg
- curl
- kid3-cli

## installation
```bash
$ git clone https://github.com/aquakenzie/soundclown --depth 1
$ cd soundclown
$ cp soundclown.sh ~/.local/bin/soundclown
```
