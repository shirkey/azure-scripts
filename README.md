# Azure Scripts

This repository includes a few Bash shell scripts that leverage Azure CLI functions. The scripts are designed to run within the Azure Portal / Azure Shell, and potentially within your own host.

## Pre-Requisites (on Azure Shell or Azure Portal)

If you already have:
- an active Microsoft Azure account
- previously logged into the [Azure Portal](https://portal.azure.com) or the [Azure Shell](https://shell.azure.com)
- selected Bash from the two shell options

... then you should be "good to go!" -- just follow the usage instructions below to get started

## Usage

To launch the shell scripts directly, open your Azure shell. 

> Important: Check to ensure you have selected Bash from the shell pulldown, or when prompted (if this is your first time in launching the Azure shell). **This shell script is *not* designed to run in PowerShell.** 

Next, you can execute the command directly by copying/pasting the following Bash one-liner into the shell prompt:

```bash
bash <(curl -s https://raw.githubusercontent.com/shirkey/azure-scripts/master/run.sh)
```

When prompted, select your Azure subscription and Azure region from the menus, and select the function you would like to execute in your Azure account.

## Privacy

This script is designed to be standalone, executing within the privileges of your own Azure account. **No data is communicated from this script outside of your own Azure shell environment**. Any data is cached to a temporary directory within your shell environment to help reduce potential backpressure on the Azure API through repeated calls. The use of this script leverages the Azure CLI and should not incur any additional charges on your Azure subscription. 

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)
