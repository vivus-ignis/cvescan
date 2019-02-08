abstract class VulnerabilitiesDecider

  @package_manager : PackageManager

  def initialize(pkgman)
    @package_manager = pkgman
  end

  abstract def report : Array(Vulnerability)

end
