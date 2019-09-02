{ stdenv, meson, ninja, gettext, fetchurl
, pkgconfig, gtk3, glib, libsoup, gsettings-desktop-schemas
, itstool, libxml2, python3Packages, libhandy
, gnome3, gdk-pixbuf, libnotify, gobject-introspection, wrapGAppsHook }:

let
  pname = "gnome-tweaks";
  version = "3.33.90";
in stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${name}.tar.xz";
    sha256 = "0vq20895kqv7kd11ainc8r0bf27m3pplvk1wrd4vk9yg2ra0cbhf";
  };

  nativeBuildInputs = [
    meson ninja pkgconfig gettext itstool libxml2 wrapGAppsHook python3Packages.python
  ];
  buildInputs = [
    gtk3 glib gsettings-desktop-schemas
    gdk-pixbuf gnome3.adwaita-icon-theme
    libnotify gnome3.gnome-shell python3Packages.pygobject3
    libsoup gnome3.gnome-settings-daemon gnome3.nautilus
    gnome3.mutter gnome3.gnome-desktop gobject-introspection
    gnome3.nautilus libhandy
    # Makes it possible to select user themes through the `user-theme` extension
    gnome3.gnome-shell-extensions
  ];

  postPatch = ''
    patchShebangs meson-postinstall.py
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PYTHONPATH : "$out/${python3Packages.python.sitePackages}:$PYTHONPATH")
  '';

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "gnome3.${pname}";
    };
  };

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/action/show/Apps/GnomeTweakTool;
    description = "A tool to customize advanced GNOME 3 options";
    maintainers = gnome3.maintainers;
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
