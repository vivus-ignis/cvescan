require "../distro"
require "../package_manager/*"

class Distro::Manjaro < Distro

  def initialize
    super

    @package_managers << PackageManager::Pacman.new
  end

  def name
    "manjaro"
  end

  # rolling
  def release
    "0.0.1"
  end

end
