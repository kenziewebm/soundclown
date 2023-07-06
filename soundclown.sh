#!/usr/bin/env bash

function usage() {
    echo "usage: $(basename $0) <url/id> [file]"
    echo "    url - soundcloud url or song id"
    echo "    file - output file (format is opus)"
    echo ""
    echo "if file isnt specified then song info will be"
    echo "displayed instead of the song being downloaded"
    exit $1
}

function version() {
    echo "soundclown v1.0"
}

function parser() {
    filename="$2"
    if [ -z $1 ]; then
        usage 1
    fi

    if [[ "$1" == *"soundcloud.com"* ]]; then
        url="$1"
    else
        url="https://soundcloud.com/$1"
    fi

    if [ -z $filename ]; then
	check_deps
        dl_tags $url
        echo "track name: $song_name"
        echo "artist: $artist_name"
        echo "album art url: $thumbnail_url"
    else
	check_deps
        dl_audio $url $filename
        dl_tags $url
        curl $thumbnail_url -L | ffmpeg -i - /tmp/cover.png
        tag_file $filename
        rm /tmp/cover.png
    fi
}

function dl_audio() {
    yt-dlp "$url" -o - | ffmpeg -i - -c:a libopus "$filename" # opus ensures we can embed album art and tags
}

function dl_tags() {
    url=$1
    export thumbnail_url=$(curl -s "$url" | grep itemprop | grep sndcdn | awk '{print $2}' | sed -e "s/src=\"//g" -e "s/\"$//g") # incredibly retarded
    export song_name=$(curl -s "$url" | grep itemprop=\"url\" | head -1 | sed -e "s/</ /g" -e "s/>/ /g" | awk '{for(i=6;i<=NF-1;i++) printf("%s ", $i);}') # idk what this does
    export artist_name=$(curl -s "$url" | grep byArtist | awk '{print $6}' | sed -e "s/^content=\"//g" -e "s/\"$//g") # no idea as well
}

function tag_file() {
    kid3-cli -c 'set picture:"/tmp/cover.png" ""' "$filename"
    kid3-cli -c "set artist '$artist_name'" "$filename"
    kid3-cli -c "set title '$song_name'" "$filename"
}

function check_deps() {
    for i in $(echo curl ffmpeg awk sed kid3-cli yt-dlp); do
        if [ -z $(which $i) ]; then
            echo "dep not found: $i"
            exit 1
        fi
    done
}
case $1 in
    -h|--help)
        version
        echo ""
        usage 0;;
    -v|-V|--version)
        version
        exit 0;;
    *) parser $@ ;;
esac
