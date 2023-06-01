# What does this do?
This will get you the bleeding-edge syntax highlighting for Lisp. Which means your theme will be able to color your code better.

NOTE! Disable the bracket-pair-colorizer for best effects.
Do this by adding the following to your settings.json.
```
    "[lisp]": {
        "editor.bracketPairColorization.enabled": false,
    },
```

NOTE: The default VS Code theme does not color much. Switch to the Dark+ theme (installed by default) or use a theme like one of the following to benefit from the changes:
- [XD Theme](https://marketplace.visualstudio.com/items?itemName=jeff-hykin.xd-theme)
- [Noctis](https://marketplace.visualstudio.com/items?itemName=liviuschera.noctis)
- [Kary Pro Colors](https://marketplace.visualstudio.com/items?itemName=karyfoundation.theme-karyfoundation-themes)
- [Material Theme](https://marketplace.visualstudio.com/items?itemName=Equinusocio.vsc-material-theme)
- [One Monokai Theme](https://marketplace.visualstudio.com/items?itemName=azemoh.one-monokai)
- [Winteriscoming](https://marketplace.visualstudio.com/items?itemName=johnpapa.winteriscoming)
- [Popping and Locking](https://marketplace.visualstudio.com/items?itemName=hedinne.popping-and-locking-vscode)
- [Syntax Highlight Theme](https://marketplace.visualstudio.com/items?itemName=peaceshi.syntax-highlight)
- [Default Theme Enhanced](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools-themes)

## How do I use it?
Just install the VS Code extension and the changes will automatically be applied to all relevent files.

# Before and After (Material Theme)
Before                     | After 
:-------------------------:|:-------------------------:
![before](https://github.com/jeff-hykin/better-lisp-syntax/assets/17692058/76e41da6-7f49-4aef-8c22-ba8924a0d62e) | ![after](https://github.com/jeff-hykin/better-lisp-syntax/assets/17692058/2f8f4d6a-49eb-4982-b1e9-6f2d4b198c94)
 
## Contributing
If you'd like to help improve the syntax, take a look at `main/main.rb`. And make sure to take a look at `CONTRIBUTING.md` to get a better idea of how code works.