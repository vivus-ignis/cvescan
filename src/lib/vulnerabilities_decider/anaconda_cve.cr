require "../vulnerabilities_decider"

class VulnerabilitiesDecider::AnacondaCve < VulnerabilitiesDecider

  def initialize(pkgman)
    super
  end

  def report; end

end
