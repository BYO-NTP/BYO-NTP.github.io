## SPIRIT

The intent of this site is to provide a repository of information useful to anyone wishing to build a NTP server. Lowering the barriers to entry is a primary objective.

The information in this repo is organized as follows:

| Path     | Purpose |
| -------- | --------------- |
| ./daemon | information about the NTP daemons |
| ./gnss/*.json | info on distinct GNSS products well-suited to a NTP build |
| ./gnss/module/*.json | info of the GNSS chips that power those products |
| ./os/  | Operating Systems well-suited for use in a NTP server |
| ./server | Physical servers (CPU, RAM, storage) on which to run a NTP server |


## PROCESS

To contribute a recipe, create a [Pull Request](https://github.com/BYO-NTP/recipes/pulls) which contains:

1. the recipe itself in ./recipes
2. any additions to ./os/, ./gnss/, or ./server/

Make sure the links work and expect another volunteer to review your PR, preferably attempting to replicate your build.

## STYLE

- Regarding capitalization, when displaying information about a product or release, adhere to the styling the project owner(s) use.
- Remove elements that aren't URL safe and can be capably substituted with whitespace.
- 
