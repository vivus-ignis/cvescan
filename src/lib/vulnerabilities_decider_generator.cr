require "./exceptions"
require "./vulnerabilities_decider/*"

# Produces a *VulnerabilitiesDecider* object that suits given Linux
# distribution and package manager
class VulnerabilitiesDeciderGenerator

  def self.for(distro, package_manager)
    if package_manager.class == PackageManager::Dpkg
      case distro.name
      when "debian"
        return VulnerabilitiesDecider::Debsecan.new package_manager
      when "ubuntu"
        return VulnerabilitiesDecider::UbuntuPackagesChangelog.new package_manager
      end
    end

    case package_manager
    when PackageManager::Rpm
      return VulnerabilitiesDecider::RpmToCve.new package_manager
    when PackageManager::Apk
      return VulnerabilitiesDecider::AlpineSecDb.new(package_manager, distro.release)
    when PackageManager::Gem
      return VulnerabilitiesDecider::RubyAdvisoryDb.new package_manager
    when PackageManager::Conda
      return VulnerabilitiesDecider::AnacondaCve.new package_manager
    when PackageManager::Pip
      return VulnerabilitiesDecider::PythonSafetyDb.new package_manager
    when PackageManager::Npm
      return VulnerabilitiesDecider::NpmAudit.new package_manager
    when PackageManager::Pacman
      return VulnerabilitiesDecider::Dummy.new package_manager
    else
      raise NotSupported.new("No vulnerabilities decider defined for the combination of " \
                               "#{distro.class} distribution and #{package_manager.class} package manager")
    end
  end

end
