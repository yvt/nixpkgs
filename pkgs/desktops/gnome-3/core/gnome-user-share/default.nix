{ stdenv
, gettext
, meson
, ninja
, fetchurl
, apacheHttpd
, nautilus
, pkgconfig
, gtk3
, glib
, libxml2
, systemd
, wrapGAppsHook
, itstool
, libnotify
, mod_dnssd
, gnome3
, libcanberra-gtk3
, python3
}:

stdenv.mkDerivation rec {
  pname = "gnome-user-share";
  version = "3.34.0";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "04r9ck9v4i0d31grbli1d4slw2d6dcsfkpaybkwbzi7wnj72l30x";
  };

  postPatch = ''
    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
  '';

  preConfigure = ''
    sed -e 's,^LoadModule dnssd_module.\+,LoadModule dnssd_module ${mod_dnssd}/modules/mod_dnssd.so,' \
      -e 's,''${HTTP_MODULES_PATH},${apacheHttpd}/modules,' \
      -i data/dav_user_2.4.conf
  '';

  NIX_CFLAGS_COMPILE = "-I${glib.dev}/include/gio-unix-2.0";

  mesonFlags = [
    "-Dhttpd=['${apacheHttpd.out}/bin/httpd']"
    "-Dmodules_path=${apacheHttpd.dev}/modules"
    "-Dsystemduserunitdir=${placeholder "out"}/etc/systemd/user"
    # not exposed with meson
    # "-Dwith-nautilusdir=${placeholder "out"}/lib/nautilus/extensions-3.0"
  ];

  nativeBuildInputs = [
    pkgconfig
    meson
    ninja
    gettext
    itstool
    libxml2
    wrapGAppsHook
    python3
  ];

  buildInputs = [
    gtk3
    glib
    nautilus
    libnotify
    libcanberra-gtk3
    systemd
  ];

  doCheck = true;

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "gnome3.${pname}";
    };
  };

  meta = with stdenv.lib; {
    homepage = https://help.gnome.org/users/gnome-user-share/3.8;
    description = "Service that exports the contents of the Public folder in your home directory on the local network";
    maintainers = gnome3.maintainers;
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
