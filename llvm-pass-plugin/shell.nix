{pkgs ? import <nixos> {}, rv32 ? import <nixos> {crossSystem = { config = "riscv32-unknown-linux-gnu"; }; }}:
pkgs.mkShell {
  packages = [
    pkgs.gcc
    pkgs.gnumake
    pkgs.clang_16
  ];
  buildInputs = [
    pkgs.libxml2
    pkgs.llvm_16
  ];
  LLVM_SYS_160_PREFIX = "${pkgs.llvm_16.dev}";
}