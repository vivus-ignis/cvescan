require "./package"

abstract class PackageManager

  @installed : Array(Package)
  @available : Array(Package)           # all the packages available for install from all repositories
  @upgrade_candidates : Array(Package)  # highest-version-possible upgrade candidates for installed packages
  @upgradable : Array(Package)          # installed packages for which there are newer versions (upgrade candidates)

  def initialize
    @installed = installed
    @available = available
    @upgrade_candidates = upgrade_candidates
    @upgradable = upgradable
  end

  abstract private def architecture : String

  abstract def installed : Array(Package)

  abstract def available : Array(Package)

  abstract def upgrade_candidates : Array(Package)

  abstract def upgradable : Array(Package)

end
