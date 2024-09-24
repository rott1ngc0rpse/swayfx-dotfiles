#!/bin/bash

# Configuration
ALBUM_ART_TEMP="/tmp/album_art.jpg"
MUSIC_DIR="$HOME/Music"

# Function to get album art using ffmpegthumbnailer
get_album_art() {
    local file="$1"
    if [ -f "$file" ]; then
        ffmpegthumbnailer -i "$file" -o "$ALBUM_ART_TEMP" -s 128 2>/dev/null
    else
        echo "Error: File does not exist: $file"
        rm -f "$ALBUM_ART_TEMP"
    fi
}

# Function to show notification using mako
show_notification() {
    local title="$1"
    local artist="$2"
    local album="$3"
    local art="$4"
    local message="$title - $artist\nAlbum: $album"
    if [ -f "$art" ]; then
        notify-send -i "$art" "Now Playing" "$message"
    else
        notify-send "Now Playing" "$message"
    fi
}

# Function to handle song change
handle_song_change() {
    local file=$(mpc current -f "%file%")
    local title=$(mpc current -f "%title%")
    local artist=$(mpc current -f "%artist%")
    local album=$(mpc current -f "%album%")

    # Convert relative path to absolute path
    file="$MUSIC_DIR/$file"

    get_album_art "$file"
    show_notification "$title" "$artist" "$album" "$ALBUM_ART_TEMP"
}

# Start MPD if it's not already running
if ! pgrep -x mpd > /dev/null; then
    mpd
fi

# Initial notification
handle_song_change

# Use mpc idleloop to monitor for changes
mpc idleloop | while read -r event; do
    if [ "$event" = "player" ]; then
        handle_song_change
    fi
done
