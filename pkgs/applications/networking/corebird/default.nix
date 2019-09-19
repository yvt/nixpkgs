{ stdenv, fetchFromGitHub, fetchpatch, glib, gtk3, json-glib, sqlite, libsoup, gettext, vala, gspell
, meson, ninja, pkgconfig, gnome3, gst_all_1, wrapGAppsHook, gobject-introspection
, glib-networking, python3 }:

stdenv.mkDerivation rec {
  version = "1.7.4";
  pname = "corebird";

  src = fetchFromGitHub {
    owner = "baedert";
    repo = "corebird";
    rev = version;
    sha256 = "0qjffsmg1hm64dgsbkfwzbzy9q4xa1q4fh4h8ni8a2b1p3h80x7n";
  };

  patches = [
    # Fix build with recent Vala
    # https://github.com/baedert/corebird/pull/849
    (fetchpatch {
      url = https://github.com/baedert/corebird/commit/3b6c912153fd7740a29ee965c9f8e46953962c33.patch;
      sha256 = "0gpk7fpfmdascgx6j8dhhmy0r7w8li3f7cph39kg2a040sqpfryj";
    })
  ];

  nativeBuildInputs = [
    meson ninja vala pkgconfig wrapGAppsHook python3
    gobject-introspection # for setup hook
  ];

  buildInputs = [
    glib gtk3 json-glib sqlite libsoup gettext gnome3.dconf gspell glib-networking
  ] ++ (with gst_all_1; [ gstreamer gst-plugins-base gst-plugins-bad (gst-plugins-good.override { gtkSupport = true; }) gst-libav ]);

  postPatch = ''
    chmod +x data/meson_post_install.py # patchShebangs requires executable file
    patchShebangs data/meson_post_install.py
  '';

  meta = with stdenv.lib; {
    description = "Native GTK Twitter client for the Linux desktop";
    longDescription = "Corebird is a modern, easy and fun Twitter client.";
    homepage = https://corebird.baedert.org/;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ jonafato jtojnar ];
  };
}
