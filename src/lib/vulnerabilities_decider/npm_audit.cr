require "../vulnerabilities_decider"

class VulnerabilitiesDecider::NpmAudit < VulnerabilitiesDecider

  def initialize(pkgman)
    super
  end

  def report; end

end
