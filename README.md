# Solar2D Definitions

This is a simple project that aims to generate valid Solar2D definitions for usage with the actual lua LSP in editors like vscode ,sublime text 4, neovim, etc.

It can also be extended to generate definitions for other languages like teal or typescript. If you do that, please commit to this repository, look at solarparsed.lua (generated) and generator.lua to have some inspiration

## How to use

Clone this repository, then run this commands inside the cloned folder

1. Clone the official docs repository using
`git clone https://github.com/coronalabs/corona-docs`

2. Run the actual parser using `lua54 main.lua` if you are on Windows. For other systems you need to use your installed lua binary. Don't delete the out folder since that is where the output files will be

3. The output declarations will be inside the `out` folder. Use them according to your needs, for a simple way of integration just create a folder called types (or whatever) on your project and place the lua files there,

### Thanks

A huge thanks to andrei18 for making a base project for this one https://forums.solar2d.com/t/zerobrane-studio-corona-api-2020-3606/351996/4´

A huge thanks to EmreErdogan for giving the markdown locations https://forums.solar2d.com/t/solar2d-typescript/354688
