require "../vulnerabilities_decider"

class VulnerabilitiesDecider::PythonSafetyDb < VulnerabilitiesDecider

  def initialize(pkgman)
    super
  end

  def report; end

end
