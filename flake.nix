{
  description = "Convert currencies as of certain date";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    mach-nix.url = "github:DavHau/mach-nix";
  };

  outputs = { self, nixpkgs, flake-utils, mach-nix, ... }@inputs:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };

          requirements-txt = "${self}/requirements.txt";

          # python environment
          mypython = with pkgs;
            [
              (mach-nix.lib."${system}".mkPython {
                requirements = builtins.readFile requirements-txt;
              })
            ];
          
          # Utility to run a script easily in the flakes app
          simple_script = name: add_deps: text: let
            exec = pkgs.writeShellApplication {
              inherit name text;
              runtimeInputs = with pkgs; [
                (mach-nix.lib."${system}".mkPython {
                  requirements = builtins.readFile requirements-txt;
                })
              ] ++ add_deps;
            };
          in {
            type = "app";
            program = "${exec}/bin/${name}";
          };

          pyscript = "${self}/currency-exchange.py";

        in with pkgs;
          {
            ###################################################################
            #                       package                                   #
            ###################################################################
            packages = {
              currency-exchange = stdenv.mkDerivation {
                runtimeInputs = [ mypython ];
                buildInputs = [ mypython ];
                src = ./.;
                name="currency-exchange";
                installPhase = ''
                  mkdir -p $out/bin/
                  cp ${self}/currency-exchange.sh $out/bin/currency-exchange
                '';
                
              };
            };
            
            ###################################################################
            #                       running                                   #
            ###################################################################
            apps = {
              default = simple_script "pyscript" [] ''
                python ${pyscript} "''$@"
              '';
            };

            ###################################################################
            #                       development shell                         #
            ###################################################################
            devShells.default = mach-nix.lib."${system}".mkPythonShell # mkShell
              {
                # requirement
                requirements = builtins.readFile requirements-txt;
              };
          }
      );
}
