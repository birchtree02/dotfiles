#!/usr/bin/env osascript

-- maintainer: cdrani
-- Returns Spotify current player state and scrolling song info

on getPlayerState(player_state)
    if player_state is "playing" then
        return "♫ ⏵ "
    else if player_state is "paused" then
        return "♫ ⏸ "
    else
        return "♫ 💤"
    end if
end getPlayerState

on scrollText(text_to_scroll, max_length)
    -- Return the text as-is if its length is less than or equal to max_length
    if (length of text_to_scroll) ≤ max_length then
        return text_to_scroll
    end if

    -- Concatenate text to itself for seamless scrolling
    set looping_text to text_to_scroll & "  " & text_to_scroll

    -- Get the current time-based index for scrolling
    set current_time to do shell script "date +%s"
    set scroll_index to (current_time mod (length of text_to_scroll)) + 1

    -- Extract the scrolling window
    return text scroll_index thru (scroll_index + max_length - 1) of looping_text
end scrollText

on printSongInfo(player_state, track_name, album_name, artist_name)
    set full_text to track_name
    return getPlayerState(player_state) & " " & scrollText(full_text, 38) -- Set scrolling window to 38 characters
end printSongInfo

tell application "Spotify"
    if it is not running then
        return "♫ 💤"
    end if

    set track_name to name of current track
    set artist_name to artist of current track
    set album_name to album of current track
    set player_state to player state as string

    if player_state is "paused" then
      return "♫ 💤"
    end if

    return my printSongInfo(player_state, track_name, album_name, artist_name)
end tell

