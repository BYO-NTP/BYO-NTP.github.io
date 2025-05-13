## SPIRIT

The intent of this site is to provide a repository of information useful to others who follow us. With that in mind, keeping the barriers to use and contributions low is a primary objective.

The information in this repo is organized as follows:

| Path     | Purpose |
| -------- | --------------- |
| ./daemon | information about the NTP daemons |
| ./gnss/*.json | info on distinct GNSS products well-suited to a NTP build |
| ./gnss/module/*.json | info of the GNSS chips that power those products |
| ./os/  | Operating Systems well-suited for use in a NTP server |
| ./server | Physical servers (CPU, RAM, storage) on which to run a NTP server |


## PROCESS

To contribute a recipe, one would create a [Pull Request](https://github.com/BYO-NTP/recipes/pulls) which contains:

1. the recipe itself in ./recipes
2. additions to ./os/*.json
3. additions to ./gnss/*.json
4. additions to ./server/*.json

## STYLE

- Regarding capitalization, when displaying information about a product or release, adhere to the styling the project owner(s) use.
- Remove elements that aren't URL safe and can be capably substited with whitespace.
- 
