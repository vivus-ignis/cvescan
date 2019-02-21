class PackageManager::Apk < PackageManager
  def initialize
    super

    Utils.dputs "installed : #{Utils.snip @installed} (count: #{@installed.size})"
  end

  private def architecture : String
    File.read("/etc/apk/arch").chomp
  end

  private def repositories : Array(String)
    File.read_lines("/etc/apk/repositories")
  end

  # /lib/apk/db/installed
  def installed
    File.read_lines("/lib/apk/db/installed")
      .select { |line| line.starts_with?("P:") || line.starts_with?("V:") }
      .in_groups_of(2)
      .map { |pkg_a| pkg_a.map { |x| x.not_nil!.split(":") }.to_h }
      .map { |pkg_h| Package.new(pkg_h["P"],
                                 pkg_h["V"]) }
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
