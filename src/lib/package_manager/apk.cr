class PackageManager::Apk < PackageManager
  def initialize
    super
  end

  def installed
    [] of Package
  end

  def available
    [] of Package
  end

  def upgrade_candidates
    [] of Package
  end

  def upgradable
    [] of Package
  end
end
