require "../vulnerabilities_decider"

class VulnerabilitiesDecider::UbuntuPackagesChangelog < VulnerabilitiesDecider

  def initialize(pkgman)
    super
  end

  def report; end

end
