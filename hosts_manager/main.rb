# encoding: utf-8

require 'rubygems' unless defined? Gem
require './bundle/bundler/setup'

require 'irb'
require 'alfred'
require 'ipaddr'
require './hosts_workflow'

class IPAddr
  def self.valid? ip
    !(IPAddr.new(ip) rescue nil)
  end
end

module Alfred
  class Feedback
    class Item
      def host_match? query
        if query.is_a? String
          action = query.split("\s").first
        elsif query.is_a? Array
          action = query.first
        end

        return true if query.empty?
        return false if action == 'add'
        return false unless IPAddr.valid? action
        !!smartcase_query(query).match(@title)
      end
    end
  end
end

Alfred.with_friendly_error do |alfred|
  alfred.with_rescue_feedback = true

  feedback = alfred.feedback
  workflow = HostsWorkflow.new

  workflow.fill_feedback feedback
  puts feedback.to_xml ARGV
end
