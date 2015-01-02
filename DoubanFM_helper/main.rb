# encoding: utf-8

require 'rubygems' unless defined? Gem
require './bundle/bundler/setup'

require 'alfred'
require './douban_fm'

module Alfred
  class Feedback
    class Item
      def action_match? query
        return true if query.empty?
        smartcase_query(query).match @arg
      end
    end

    def clean_cache
      File.delete backend_file
    end
  end
end

def show_options feedback
  DoubanFM::ACTION.each do |action, desc|
    feedback.add_item(
      uid: action,
      title: desc,
      arg: action,
      match?: :action_match?,
      autocomplete: 'autocomplete'
    )
  end

  feedback.add_item(
    uid: 'share',
    title: '复制分享链接',
    arg: 'share',
    match?: :action_match?,
    autocomplete: 'autocomplete'
  )

  current_song = DoubanFM.current_song
  like_status = if DoubanFM.liked? then '♥' else '♡' end
  play_status = if DoubanFM.paused? then '‖' else '►' end
  feedback.add_item(
    uid: 'song_name',
    title: "#{like_status} #{play_status} #{current_song['song_name']} - #{current_song['artist']}",
    autocomplete: 'autocomplete',
    order: 257
  )
end

def show_requirement feedback
  feedback.add_item(
    uid: 'requirement',
    title: '请先使用 Homebrew 安装 Chrome-cli',
    autocomplete: 'autocomplete'
  )
end

def show_need_tab feedback
  feedback.add_item(
    uid: 'need_tab',
    title: '找不到豆瓣电台标签页',
    autocomplete: 'autocomplete'
  )
end

def do_action feedback, command
  DoubanFM.act command
end

Alfred.with_friendly_error do |alfred|
  alfred.with_rescue_feedback = true
  alfred.with_cached_feedback do
    # 过期时间一分钟
    use_cache_file expire: 1 * 60
  end

  feedback = alfred.feedback

  command = ARGV[0]

  if not DoubanFM.cli_avaiable?
    show_requirement feedback
    puts feedback.to_xml
  elsif not DoubanFM.tab_exist?
    show_need_tab feedback
    puts feedback.to_xml
  elsif command.nil? or command.empty?
    if (fb = feedback.get_cached_feedback).nil?
      show_options feedback
      feedback.put_cached_feedback
    else
      feedback = fb
    end
    puts feedback.to_xml command
  elsif command == 'share'
    puts DoubanFM.current_song['url']
  else
    do_action feedback, command
    feedback.clean_cache()
  end
end
