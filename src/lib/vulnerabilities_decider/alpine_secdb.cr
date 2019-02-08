require "../vulnerabilities_decider"

class VulnerabilitiesDecider::AlpineSecDb < VulnerabilitiesDecider

  def initialize(pkgman)
    super
  end

  def report; end

end
