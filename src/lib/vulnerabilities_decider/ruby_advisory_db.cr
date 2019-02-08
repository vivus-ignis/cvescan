require "../vulnerabilities_decider"

class VulnerabilitiesDecider::RubyAdvisoryDb < VulnerabilitiesDecider

  def initialize(pkgman)
    super
  end

  def report; end

end
