require "../vulnerabilities_decider"

class VulnerabilitiesDecider::RpmToCve < VulnerabilitiesDecider

  def initialize(pkgman)
    super
  end

  def report; end

end
