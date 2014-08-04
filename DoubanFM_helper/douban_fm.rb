# encoding: utf-8

require 'json'

CLI_NAME = 'chrome-cli'

module DoubanFM
  ACTION = {
    skip: '跳过',
    pause: '播放/暂停',
    love: '喜欢/不喜欢',
    ban: '不再播放'
  }

  def self.cli_avaiable?
    `hash #{CLI_NAME} 2>/dev/null`
    $?.success?
  end

  def self.tab_exist?
    not fm_tab_id.nil?
  end

  def self.fm_tab_id
    response = `#{CLI_NAME} list tabs | grep 豆瓣FM`
    return nil unless $?.success?
    response[/^\[(\d+)\]/, 1]
  end

  def self.execute_js code
    response = `#{CLI_NAME} execute "#{code}" -t #{fm_tab_id}`
    unless $?.success?
      raise RuntimeError, "JavaScript execute error, detail: #{response}"
    end
    response.sub /\n$/, ''
  end

  def self.current_song
    data = JSON.parse execute_js 'localStorage.bubbler_song_info'
    data['liked'] = execute_js('DBR.selected_like()') == '1'
    data
  end

  def self.act command
    unless ACTION.keys.include? command.to_sym
      raise RuntimeError, "#{command} isn't a valid command"
    end
    execute_js "DBR.act('#{command}')"
  end
end

