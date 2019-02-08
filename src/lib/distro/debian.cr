require "../distro"
require "../package_manager/*"

class Distro::Debian < Distro

  def initialize
    super

    @package_managers << PackageManager::Dpkg.new
  end

  def name
    "debian"
  end

  def release
    File.read("/etc/debian_version").chomp
  end

end
