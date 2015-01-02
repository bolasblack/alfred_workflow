require 'hosts'

module Aef
  module Hosts
    class File
      def entries
        elements.select { |element| element.is_a? Entry }
      end
    end
  end
end

class HostsWorkflow
  def hosts
    @hosts ||= Hosts::File.read '/etc/hosts'
  end

  def write
    hosts.write force_generation: true
  end

  def add_entry ip, entry_name
    hosts.elements << Hosts::Entry.new(ip, entry_name)
    puts "Host #{entry_name} added!"
    write
  end

  def remove_entry entry_name
    hosts.elements.select! do |element|
      if element.is_a? Hosts::Entry
        element.name != entry_name
      else
        true
      end
    end
    puts "Host #{entry_name} deleted!"
    write
  end

  def fill_feedback feedback
    hosts.entries.each do |entry|
      feedback.add_item(
        uid: entry.name,
        arg: "remove #{entry.name}",
        title: entry.name,
        subtitle: entry.address,
        match?: :host_match?,
        autocomplete: 'autocomplete'
      )
    end
  end
end
