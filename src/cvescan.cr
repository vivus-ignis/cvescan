{% if flag?(:build) %}
require "llvm/lib_llvm"
require "llvm/enums"
{% end %}

require "option_parser"
require "json"

require "./lib/utils"

module Cvescan
  VERSION = "0.1.0"

  extend self

  def main
    plaintext = false

    OptionParser.parse! do |parser|
      parser.banner = "Usage: cvescan [options]"
      parser.on("-p", "--plaintext", "Report in plaintext instead of JSON") { plaintext = true }
      parser.on("-h", "--help", "Show this help") { puts parser }
      parser.invalid_option do |flag|
        STDERR.puts "ERROR: #{flag} is not a valid option."
        STDERR.puts parser
        exit(1)
      end
    end

    elapsed_time = Time.measure do
      system = Utils.detect_distro
      vulns = system.vulnerabilities
      plaintext ? vulns.to_s : vulns.to_json
    end

    Utils.dputs("Execution took #{elapsed_time}")
  end
end

{% if flag?(:build) %}
Cvescan.main
{% end %}
