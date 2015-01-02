# encoding: utf-8

require 'rubygems' unless defined? Gem
require './bundle/bundler/setup'

require 'alfred'
require './hosts_workflow'

Alfred.with_friendly_error do |alfred|
  alfred.with_rescue_feedback = true

  workflow = HostsWorkflow.new

  if ARGV.first == 'add'
    workflow.add_entry '127.0.0.1', ARGV[1]
  elsif ARGV.first == 'remove'
    workflow.remove_entry ARGV[1]
  elsif ARGV.length == 2
    workflow.add_entry *ARGV
  end
end
