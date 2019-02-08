class PackageManager::Gem < PackageManager
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
