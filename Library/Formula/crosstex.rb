require 'formula'

class Crosstex < Formula
  homepage 'http://www.cs.cornell.edu/people/egs/crosstex/'
  url 'https://github.com/el33th4x0r/crosstex/archive/master.zip'
  sha1 'fac3efc660bc55962474bd9a800a8f0fdcc3c862'
  version '0.7.0'
  
  resource 'python-ply' do
    url 'http://www.dabeaz.com/ply/ply-3.4.tar.gz'
    sha1 '123b9449b838dc387b240ea737a33b6407e5a1ac'
  end

  depends_on :python

  def wrap bin_file, pythonpath
    bin_file = Pathname.new bin_file
    libexec_bin = Pathname.new libexec/'bin'
    libexec_bin.mkpath
    mv bin_file, libexec_bin
    bin_file.write <<-EOS.undent
      #!/bin/sh
      PYTHONPATH="#{pythonpath}:$PYTHONPATH" "#{libexec_bin}/#{bin_file.basename}" "$@"
    EOS
  end

  def install
    lib_install = [ "setup.py", "install", "--prefix=#{libexec}" ]
    app_install = [ "setup.py", "install", "--prefix=#{prefix}" ]

    python do
      resource('python-ply').stage { system "python", *lib_install }

      inreplace 'crosstex/__init__.py',
                "import copy",
                "import copy; import site; site.addsitedir('#{python.private_site_packages}')"

      system "python", *app_install

      Dir["#{bin}/*"].each do |bin_file|
        wrap bin_file, python.site_packages
      end
    end

  end

  test do
    system "#{bin}/crosstex", "--version"
  end
end
