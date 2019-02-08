require "../distro"
require "../package_manager/*"

class Distro::Alpine < Distro

  def initialize
    super

    @package_managers << PackageManager::Apk.new
  end

  def name
    "alpine"
  end

  def release
    File.read("/etc/alpine-release").chomp
  end

end
