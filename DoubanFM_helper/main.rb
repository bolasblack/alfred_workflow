# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
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
  song_name = current_song['song_name']
  song_name += ' [喜欢]' if current_song['liked']
  feedback.add_item(
    uid: 'song_name',
    title: "当前：#{song_name}",
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

  unless DoubanFM.cli_avaiable?
    show_requirement feedback
    puts feedback.to_xml
    return
  end

  unless DoubanFM.tab_exist?
    show_need_tab feedback
    puts feedback.to_xml
    return
  end

  command = ARGV[0]
  if command.nil? or command.empty?
    if (fb = feedback.get_cached_feedback).nil?
      show_options feedback
      feedback.put_cached_feedback
    else
      feedback = fb
    end
    puts feedback.to_xml
  elsif command == 'share'
    puts DoubanFM.current_song['url']
  else
    do_action feedback, command
    feedback.clean_cache()
  end
end

