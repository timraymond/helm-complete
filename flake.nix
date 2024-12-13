{
  description = "Vim completion plugin for Helm values.yaml";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      nixpkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };
    in
    {
      packages = nixpkgs.lib.genAttrs supportedSystems (system: 
        let
          pkgs = nixpkgsFor system;
        in
        {
          default = self.packages.${system}.vim-helm-complete;
          
          vim-helm-complete = pkgs.vimUtils.buildVimPlugin {
            pname = "helm-complete";
            version = "0.1.0";
            src = ./.;
            
            meta = with pkgs.lib; {
              description = "Vim completion plugin for Helm values.yaml";
              homepage = "https://github.com/timraymond/helm-complete.vim";
              maintainers = [];
            };
          };
        }
      );

      overlays.default = final: prev: {
        vimPlugins = prev.vimPlugins // {
          vim-helm-complete = self.packages.${prev.system}.vim-helm-complete;
        };
      };
    };
}
