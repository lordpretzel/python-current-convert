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
          mypython = 
              mach-nix.lib."${system}".mkPython {
                requirements = builtins.readFile requirements-txt;
              };

          #pybin = "${mypython.python}/bin/python";
          
          # Utility to run a script easily in the flakes app
          simple_script = name: add_deps: text: let
            exec = pkgs.writeShellApplication {
              inherit name text;
              runtimeInputs = with pkgs; [
                mypython
              ] ++ add_deps;
            };
          in {
            type = "app";
            program = "${exec}/bin/${name}";
          };

          # the python script to wrap as an app
          script-name = "currency-exchange.py";
          pyscript = "${self}/${script-name}";

          #pypyt = builtins.trace mypython.python "";
          
        in with pkgs;
          {
            ###################################################################
            #                       package                                   #
            ###################################################################
            packages = {
              currency-exchange = stdenv.mkDerivation {
                name="currency-exchange-1.0";
                src = ./.;
                
                runtimeInputs = [ mypython ];
                buildInputs = [ mypython ];
                nativeBuildInputs = [ makeWrapper ];
                installPhase = ''
                  mkdir -p $out/bin/
                  mkdir -p $out/share/
                  cp ${pyscript} $out/share/currency-exchange.py
                  makeWrapper ${mypython}/bin/python $out/bin/currency-exchange --add-flags "$out/share/${script-name}" 
                '';                
              };
            };
#makeWrapper python $out/bin/currency-exchange --add-flags "$out/share/${script-name}"
            #                  cp ${self}/currency-exchange.sh $out/bin/currency-exchange
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
            devShells.default = mkShell
              {
                runtimeInputs = [ mypython ];
#                 shell-hook = ''
#                   echo "${mypython.python.pkgs.python}"
# '';
              };
          }
      );
}
