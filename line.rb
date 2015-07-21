#!/usr/bin/env ruby
require 'ruby-mpd'
require 'socket'

E_NO_MUSIC_STRING = 'No music playing'

def truncate(str, start=0, len=10)
  return str.length > 10 ? str[start..(len - 1)] : str
end

def status_line
  client = MPD.new

  begin
    client.connect
  rescue Errno::ECONNREFUSED
    return E_NO_MUSIC_STRING
  end

  song = client.current_song
  return E_NO_MUSIC_STRING if song.nil?

  song_string = "#{truncate song.title} - #{truncate song.artist}"
  if client.paused?
    return "[PAUSED] #{song_string}"
  elsif client.stopped?
    return "[STOPPED] #{song_string}"
  elsif client.playing?
    return "[PLAYING] #{song_string}"
  else
    return "[UNKNOWN] #{song_string}"
  end
end

def looper
  str = nil
  serv = UNIXServer.new('/tmp/music.sock')

  loop do
    while str == status_line
      s = serv.accept
      s.puts truncate(str)

      s_idx += 1
      e_idx += 1
    end

    s_idx = 0
    e_idx = 9
    str = status_line
  end
end

puts status_line
