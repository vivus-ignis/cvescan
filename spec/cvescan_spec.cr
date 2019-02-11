require "./spec_helper"

describe Cvescan do

  describe PackageVersion do

    # testcases are taken from https://bugs.debian.org/cgi-bin/bugreport.cgi?att=2;bug=432269;filename=debian_version_test.rb;msg=5
    # reference check:
    # (docker run --rm -ti debian:jessie dpkg --compare-versions "2.11" "lt" "3") && echo "true"
    testcases= [
                 {"1", "2", -1},
                 {"1", "1", 0},
                 {"2", "1", 1},
                 {"1.0", "1.1", -1},
                 {"1.2.3", "1.2.1", 1},
                 {"1.0.0.1", "1.0.0.1", 0},
                 {"1.0", "1.0-0", 0},
                 {"1.0-1", "1.0-0", 1},
                 {"1.0-1", "1.0-0.1", 1},
                 {"1.0", "1:0.1", -1},
                 {"1.0beta1", "1.0", 1},
                 {"1.0beta1", "1.0-1", 1},
                 {"1.0", "1.0-1", -1},
                 {"1.0-1bpo1", "1.0-1", 1},
                 {"1.0-1bpo1", "1.0-1.1", -1},
                 {"1.0-1", "1.0-1~sarge1", 1},
                 {"1.0~beta1", "1.0", -1},
                 {"2.1~~pre", "2.1~alpha", -1},
                 {"2.1~alpha", "2.1~beta", -1},
                 {"2.1~beta", "2.1~rc", -1},
                 {"1.0-1", "2.0-2", -1},
                 {"2.2~rc-4", "2.2-1", -1},
                 {"2.2-1", "2.2~rc-4", 1},
                 {"1.0000-1", "1.0-1", 0},
                 {"1", "0:1", 0},
                 {"0", "0:0-0", 0},
                 {"2:2.5", "1:7.5", 1},
                 {"1:0foo", "0foo", 1},
                 {"0:0foo", "0foo", 0},
                 {"0foo", "0foo", 0},
                 {"0foo-0", "0foo", 0},
                 {"0foo", "0foo-0", 0},
                 {"0foo", "0fo", 1},
                 {"0foo-0", "0foo+", -1},
                 {"0foo~1", "0foo", -1},
                 {"0foo~foo+Bar", "0foo~foo+bar", -1},
                 {"0foo~~", "0foo~", -1},
                 {"1~", "1", -1},
                 {"12345+that-really-is-some-ver-0", "12345+that-really-is-some-ver-10", -1},
                 {"0foo-0", "0foo-01", -1},
                 {"0foo.bar", "0foobar", 1},
                 {"0foo.bar", "0foo1bar", 1},
                 {"0foo.bar", "0foo0bar", 1},
                 {"0foo1bar-1", "0foobar-1", -1},
                 {"0foo2.0", "0foo2", 1},
                 {"0foo2.0.0", "0foo2.10.0", -1},
                 {"0foo2.0", "0foo2.0.0", -1},
                 {"0foo2.0", "0foo2.10", -1},
                 {"0foo2.1", "0foo2.10", -1},
                 {"1.09", "1.9", 0},
                 {"1.0.8+nmu1", "1.0.8", 1},
                 {"3.11", "3.10+nmu1", 1},
                 {"0.9j-20080306-4", "0.9i-20070324-2", 1},
                 {"1.2.0~b7-1", "1.2.0~b6-1", 1},
                 {"1.011-1", "1.06-2", 1},
                 {"0.0.9+dfsg1-1", "0.0.8+dfsg1-3", 1},
                 {"4.6.99+svn6582-1", "4.6.99+svn6496-1", 1},
                 {"53", "52", 1},
                 {"0.9.9~pre122-1", "0.9.9~pre111-1", 1},
                 {"2:2.3.2-2+lenny2", "2:2.3.2-2", 1},
                 {"1:3.8.1-1", "3.8.GA-1", 1},
                 {"1.0.1+gpl-1", "1.0.1-2", 1},
                 {"1a", "1000a", -1},
                 {"3.3.30-0+deb8u1", "3.3.8-6+deb8u7", 1},
                 {"3.3.8-6+deb8u7", "3.3.30-0+deb8u1", -1}
                ]

    testcases.each do |t|
      it "#{t[0]} <=> #{t[1]} is #{t[2]}" do
        v1 = PackageVersion.new t[0]
        v2 = PackageVersion.new t[1]
        # puts "#{t[0]} : #{v1}"
        # puts "#{t[1]} : #{v2}"
        (v1 <=> v2).should eq t[2]
      end
    end
  end

end
