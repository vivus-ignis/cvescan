require "crest"

require "./exceptions"
require "./distro"
require "./distro/*"

module Utils
  extend self

  def is_debug_on?
    ENV.has_key? "CVESCAN_DEBUG"
  end

  def dputs(msg)
    STDERR.puts "DEBUG // #{msg}" if is_debug_on?
  end

  def ddump(label, data)
    return unless is_debug_on?
    File.tempfile(label, ".dump") do |tmp|
      tmp.puts data
    end
  end

  def snip(coll)
    if coll.size > 4
      "#{coll[0..4]} ..."
    elsif coll.empty?
      "<empty>"
    else
      "#{coll.first} ..."
    end
  end

  def get_command_output(cmd, expected_retcodes = [0])
    output = IO::Memory.new
    error_output = IO::Memory.new

    cmd_arr = cmd.split
    bin = cmd_arr.first
    args = if cmd_arr.size > 1
             cmd_arr[1..-1]
           else
             nil
           end

    dputs "About to run external command: #{bin} #{args}"
    ret = Process.run(bin, args, shell: true, output: output, error: error_output)
    unless expected_retcodes.includes? ret.exit_status
      Utils.dputs "Command #{cmd} returned an error. Stderr output follows."
      Utils.dputs ">>>"
      Utils.dputs error_output
      Utils.dputs "<<<"

      raise CommandFailed.new("Command #{cmd} returned an error")
    end

    output.to_s
      .split("\n")
      .reject { |line| line == "" }
      .join("\n")
  end

  def get_remote_contents(url)
    Utils.dputs "get_remote_contents #{url}"
    response = Crest.get(url, max_redirects: 3)

    Utils.dputs "crest finished"
    Utils.dputs "response code : #{response.status_code}"
    Utils.dputs "response headers : #{response.headers}"
    Utils.dputs "response body size: #{response.body.size}"

     unless response.status_code == 200
       raise RemoteContentRetrievalFailed.new("Failed to retrieve content from #{url}, HTTP status code was: #{response.status_code}")
     end
    response.body
  end

  def detect_distro
    if is_ubuntu?
      Distro::Ubuntu.new
    elsif is_debian?
      Distro::Debian.new
    elsif is_centos?
      Distro::Centos.new
    elsif is_alpine?
      Distro::Alpine.new
    elsif is_manjaro?
      Distro::Manjaro.new
    else
      raise NotSupported.new("This Linux distribution is not supported")
    end
  end

  def is_ubuntu?
    return false unless File.exists? "/etc/lsb-release"

    File.read_lines("/etc/lsb-release")
      .reduce({} of String => String) { |acc, x| k, v = x.split("="); acc[k] = v; acc }
      .any? { |k, v| k == "DISTRIB_ID" && v == "Ubuntu" }
  end

  def is_debian?
    return false unless File.exists? "/etc/debian_version"

    true
  end

  def is_centos?
    return false unless File.exists? "/etc/redhat-release"

    File.read("/etc/redhat-release").starts_with? "CentOS"
  end

  def is_alpine?
    return false unless File.exists? "/etc/alpine-release"

    true
  end

  def is_manjaro?
    return false unless File.exists? "/etc/lsb-release"

    File.read_lines("/etc/lsb-release")
      .reduce({} of String => String) { |acc, x| k, v = x.split("="); acc[k] = v; acc }
      .any? { |k, v| k == "DISTRIB_ID" && v == "ManjaroLinux" }
  end

end
