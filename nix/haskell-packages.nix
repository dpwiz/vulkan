# Haskell package overrides
{ pkgs ? import ./nixpkgs.nix, compiler ? null, hoogle ? false
, safeVulkanFFI ? false, safeOpenXrFFI ? false, buildProfiling ? false
, buildInstrumented ? false, openxrNoVulkan ? false }:

with pkgs.haskell.lib;

let
  gitignore = pkgs.nix-gitignore.gitignoreSourcePure ../.gitignore;
  aggressiveFilter = builtins.filterSource (path: _type:
    (pkgs.lib.any (x: baseNameOf path == x) [
      "package.yaml"
      "changelog.md"
      "readme.md"
    ]) || pkgs.lib.any (i: pkgs.lib.hasInfix i path) [
      "/src"
      "/src-manual"
      "/vk"
      "/xr"
      "/khronos-spec"
      "/vma"
    ]);
  mod = if buildProfiling then
    drv: doHaddock (enableLibraryProfiling drv)
  else
    drv: doHaddock (disableLibraryProfiling drv);

  baseHaskellPackages = if compiler == null then
    pkgs.haskellPackages
  else
    pkgs.haskell.packages.${compiler};

  overrides = self: super:
    {
      #
      # Our packages
      #
      vulkan = self.developPackage {
        name = "vulkan";
        root = aggressiveFilter ../.;
        overrides = _: _: { vulkan = pkgs.vulkan-loader; };
        modifier = mod;
        returnShellEnv = false;
        cabal2nixOptions = with pkgs.lib;
          concatStringsSep " "
          (optional safeVulkanFFI "--flag=safe-foreign-calls"
            ++ optional buildInstrumented "--flag=trace-calls");
      };
      vulkan-utils = self.developPackage {
        name = "vulkan-utils";
        root = gitignore ../utils;
        modifier = drv: addExtraLibrary (mod drv) pkgs.vulkan-headers;
        returnShellEnv = false;
      };
      VulkanMemoryAllocator = self.developPackage {
        name = "VukanMemoryAllocator";
        root = gitignore ../VulkanMemoryAllocator;
        modifier = drv: addExtraLibrary (mod drv) pkgs.vulkan-headers;
        returnShellEnv = false;
      };
      vulkan-examples = self.developPackage {
        name = "vulkan-examples";
        root = gitignore ../examples;
        modifier = drv:
          addExtraLibrary
          (addBuildTools (mod drv) [ pkgs.glslang pkgs.shaderc ])
          pkgs.renderdoc;
        returnShellEnv = false;
        cabal2nixOptions = "--flag=renderdoc";
      };
      generate-new = self.developPackage {
        name = "generate-new";
        root = aggressiveFilter ../generate-new;
        modifier = drv: dontHaddock (mod drv);
        returnShellEnv = false;
      };
      openxr = self.developPackage {
        name = "openxr";
        root = aggressiveFilter ../openxr;
        overrides = _: _: { openxr_loader = pkgs.openxr-loader; };
        modifier = mod;
        returnShellEnv = false;
        cabal2nixOptions = with pkgs.lib;
          concatStringsSep " "
          (optional openxrNoVulkan "--flag=-use-vulkan-types"
            ++ optional safeOpenXrFFI "--flag=safe-foreign-calls"
            ++ optional buildInstrumented "--flag=trace-calls");
      };

      #
      # Overrides for examples
      #
      pretty-simple = self.pretty-simple_4_0_0_0;
      prettyprinter = self.prettyprinter_1_7_0;
      derive-storable = self.callHackageDirect {
        pkg = "derive-storable";
        ver = "0.3.0.0";
        sha256 = "0h9v6k1651acsqs64mkidqrflld7ghhbiir7z9f0wm8vrqwc6wyp";
      } { };
      derive-storable-plugin = self.callHackageDirect {
        pkg = "derive-storable-plugin";
        ver = "0.2.3.3";
        sha256 = "07ikj9l5pzrh7khp0pr6pjgpygni12svfm14x0csvw0hgbsb0mnj";
      } { };
      nothunks = doJailbreak (self.callHackageDirect {
        pkg = "nothunks";
        ver = "0.1.2";
        sha256 = "1xj5xvy3x3vixkj84cwsjl3m06z2zfszbcpxbz1j1ca83ha2gb7i";
      } { });
      # profiling
      eventlog2html = markUnbroken (doJailbreak (appendPatch
        (overrideSrc super.eventlog2html {
          src = pkgs.fetchFromGitHub {
            owner = "BinderDavid";
            repo = "eventlog2html";
            rev =
              "9abc05ed94fef094b3ac54d57e00664c793b5923"; # switch-to-ghc-events-0.13
            sha256 = "0h1527zxdmail35526nn47zawsaafvsby7p50qg54wq023zazxlj";
          };
        }) (pkgs.fetchpatch {
          url = "https://github.com/mpickering/eventlog2html/pull/129.patch";
          name = "vega.patch";
          sha256 = "1lnbdscngb5g5b6ys0xhp7izdfkz6j3llnpirbfxck3sy3ssxph5";
        })));
      hs-speedscope = doJailbreak (markUnbroken
        (overrideSrc super.hs-speedscope {
          src = pkgs.fetchFromGitHub {
            owner = "mpickering";
            repo = "hs-speedscope";
            rev = "9e28b303993b79f3d943ccb89b148cb9a4fb6ca5";
            sha256 = "105zk9w5lpn0m866m8y0lhrw2x6kym2f2ryjc56zxqzfr9b76jdn";
          };
        }));
      hvega = doJailbreak (self.callHackageDirect {
        pkg = "hvega";
        ver = "0.6.0.0";
        sha256 = "1bkwp8zlb1248w95ksw71iksgd3xfw1pnb9klv8xxsqay542970a";
      } { });

      #
      # Overrides for generate
      #
      pandoc = appendPatch super.pandoc
        ../generate-new/patches/pandoc-haddock-tables.patch;
      language-c = self.language-c_0_9;
    } // pkgs.lib.optionalAttrs hoogle {
      ghc = super.ghc // { withPackages = super.ghc.withHoogle; };
      ghcWithPackages = self.ghc.withPackages;
    } // pkgs.lib.optionalAttrs (super.ghc.version == "9.0.1") {
      mkDerivation = drv:
        super.mkDerivation (drv // {
          jailbreak = true;
          doHaddock = false;
        });
    };

in baseHaskellPackages.override { inherit overrides; }
