{ stdenv, fetchurl, meson, ninja, gettext, pkgconfig, spidermonkey_52, glib
, gnome3, gnome-menus, substituteAll }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extensions";
  version = "3.34.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-shell-extensions/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "1ayb48l2p3lji7b226027293jfclgcjmdb5dd6xfn67rhxm8zgzm";
  };

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = "gnome-shell-extensions";
      attrPath = "gnome3.gnome-shell-extensions";
    };
  };

  patches = [
    (substituteAll {
      src = ./fix_gmenu.patch;
      gmenu_path = "${gnome-menus}/lib/girepository-1.0";
    })
  ];

  doCheck = true;
  # 52 is required for tests
  # https://gitlab.gnome.org/GNOME/gnome-shell-extensions/blob/3.30.1/meson.build#L25
  checkInputs = [ spidermonkey_52 ];

  nativeBuildInputs = [ meson ninja pkgconfig gettext glib ];

  mesonFlags = [ "-Dextension_set=all" ];

  preFixup = ''
    # The meson build doesn't compile the schemas.
    # Fixup adapted from export-zips.sh in the source.

    extensiondir=$out/share/gnome-shell/extensions
    schemadir=${glib.makeSchemaPath "$out" "${pname}-${version}"}

    glib-compile-schemas $schemadir

    for f in $extensiondir/*; do
      name=`basename ''${f%%@*}`
      uuid=$name@gnome-shell-extensions.gcampax.github.com
      schema=$schemadir/org.gnome.shell.extensions.$name.gschema.xml

      if [ -f $schema ]; then
        mkdir $f/schemas
        ln -s $schema $f/schemas;
        glib-compile-schemas $f/schemas
      fi
    done
  '';

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Projects/GnomeShell/Extensions;
    description = "Modify and extend GNOME Shell functionality and behavior";
    maintainers = gnome3.maintainers;
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
