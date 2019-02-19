class PackageManager::Apk < PackageManager
  def initialize
    super
  end

  private def architecture : String
    File.read("/etc/apk/arch").chomp
  end

  private def repositories : Array(String)
    File.read_lines("/etc/apk/repositories")
  end

  # /lib/apk/db/installed
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
