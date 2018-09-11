#!/usr/bin/env ruby
# encoding: UTF-8

#-$a. ------------------ .a$ ---------------------------- %$!, ----------------%
# `$¸   .%$$^¸$$aa.     .¸$`        .        .a$a$$.      `¸$%  $a$.        .
#-.aaa$ $$$$'- $$$$$.- $aaa. -.a%$^"$$aa -- .$$$$$'- $$a. $aaa. `$,$ ----------%
#;$$$$',a$a$  d$%$$$$$,'$$$$;$$$$$  $$$$$., $$%$$"  d$a$$ '$$$$; $$$   .a%$  $$a
#:$$$$;$$$$%; Z$$$$$$$$;$$$$:$$$$$. $$$$^$,;$$&$$   Z$$$$,;$$$$.a$$$a..$$$   $$$
#.$$$$ `$$$$.  $$$%$$$' $$$$.`$$$$  $$%$$$$ `$$$$.   $%$$$ $$$$""$$$" $$$$:  a$$
# `$$$a.$$%$   $$$$$$';a$$$`  `¸$$aa$$$$&$': `$$$$a. $$$$'a$$$`.$$'$  $$$$;  $$$
#%-----.------ $$$$'--------------- $$%$$' -- `¸$$$$$%$¸' ---- $$¸$a. `"$&$$#$%$
#dz      .   .:'¸'     .        .   $$$$'     .        .       `¸$$$$y.     `$$&
#%--------- a`-----------.--------- $$¸' -----.------------.---------------- $$$
#   .      !a    . .    .      .   .:'   .  .                  .        .:.a$$$¸
#.      .  '$a,          .        a` .   'a          .   .             s` .  . .
#      .    ¸$Aa         .       !a       a!      .    .         ..   %s      .s
#   .         ¸¸'     . .        '$$Aa.aA$$'        . .               `!$%a.a%#$
#==============================================================================
#   t h e    i n i q u i t y    t e r m i n a l    c l i e n t
#==============================================================================

trap("INT") {exit}

SYSTEM = ENV["INIQUITY_SYSTEM"] || Dir.pwd
ENV["INIQUITY_SYSTEM"] = SYSTEM

require "inifile"
require "github_api"
require "highline"
require "open-uri"
require "zip"
require 'rubygems'
require 'eventmachine'
require "socksify"
require "rdoc"
require "yard"

# Iniquity Terminal Client

artwork = File.join(File.dirname(File.expand_path(__FILE__)), "../artwork/sm!iniq2.asc")

IO.readlines(artwork).each do |line|
    puts line.force_encoding(Encoding::IBM437).encode(Encoding::UTF_8)
end

puts "\niqterm - The Iniquity BBS Terminal Utility.\n"

if File.exists?(SYSTEM + "/iniquity.ini")
    CONFIG = IniFile.load(SYSTEM+ "/iniquity.ini")
else
    abort "iqterm - An Iniquity system must have an iniquity.ini file.\n\n"
end

class BBSTerm < EM::Connection

    def post_init
      @initialization = true
      init_buffer
    end

    def init_buffer
      @read_buffer = ""
    end

    def receive_data(data)
      @read_buffer += data.force_encoding(Encoding::IBM437).encode(Encoding::UTF_8)

      if @initialization and @read_buffer =~ /\e\[6n/
        @initialization = false
        send_data "\e[6n\r\n"
      end

      @read_buffer.gsub!(/\r\n/, "\n")
      print @read_buffer

      init_buffer
    end
  end

  class STDINReader < EM::Connection

    def initialize(em)
      @em = em
    end

    def receive_data(data)
      my_data = data.force_encoding(Encoding::UTF_8).encode(Encoding::IBM437)
      my_data.gsub!(/\n/, "\r\n")
      EM.next_tick { @em.send_data(my_data) }
    end
  end

  EM.run do
    obj = EM.connect(ARGV[0] || "localhost", ARGV[1] || 3023, BBSTerm)
    EM.attach($stdin, STDINReader, obj)
  end