{
  stdenv,
  cmake,
  pkgconf,
  openssl,
  cryptopp,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "beatlink-cli";
  version = "1.1";
  src = fetchFromGitHub {
    owner = "Loomeh";
    repo = finalAttrs.pname;
    tag = finalAttrs.version;
    hash = "sha256-qyZYd7Cl+cc0ui+oaQ8m9Q+xDdD4KnmOizGRGytXrLk=";
  };
  patches = [
    ./01-system-libraries.patch
    ./02-gridleak.patch
    ./03-token-directory.patch
  ];
  nativeBuildInputs = [
    cmake
    pkgconf
  ];
  buildInputs = [
    openssl
    cryptopp
  ];
})
