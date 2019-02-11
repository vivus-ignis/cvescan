require "../vulnerabilities_decider"

class VulnerabilitiesDecider::Dummy < VulnerabilitiesDecider

  def initialize(pkgman)
    super
  end

  def report; end

end
