// require("dotenv").config();
// const cli = require("@aptos-labs/ts-sdk/dist/common/cli/index.js");
// const aptosSDK = require("@aptos-labs/ts-sdk")

// async function publish() {
//   if (!process.env.MODULE_ADDRESS) {
//     throw new Error(
//       "MODULE_ADDRESS variable is not set, make sure you have published the module before upgrading it",
//     );
//   }

//   const move = new cli.Move();

//   move.upgradeObjectPackage({
//     packageDirectoryPath: "contract",
//     objectAddress: process.env.MODULE_ADDRESS,
//     namedAddresses: {
//       // Upgrade module from an object
//       message_board_addr: process.env.MODULE_ADDRESS,
//     },
//     extraArguments: [`--private-key=${process.env.MODULE_PUBLISHER_ACCOUNT_PRIVATE_KEY}`,`--url=${aptosSDK.NetworkToNodeAPI[process.env.APP_NETWORK]}`],
//   });
// }
// publish();


// scripts/upgrade.js

require("dotenv").config();
const cli = require("@aptos-labs/ts-sdk/dist/common/cli/index.js");
const aptosSDK = require("@aptos-labs/ts-sdk");

async function upgrade() {
  // Check if MODULE_ADDRESS environment variable is set
  if (!process.env.MODULE_ADDRESS) {
    throw new Error(
      "MODULE_ADDRESS variable is not set, make sure you have published the module before upgrading it"
    );
  }

  // Check if MODULE_PUBLISHER_ACCOUNT_PRIVATE_KEY is set
  if (!process.env.MODULE_PUBLISHER_ACCOUNT_PRIVATE_KEY) {
    throw new Error(
      "MODULE_PUBLISHER_ACCOUNT_PRIVATE_KEY variable is not set, make sure you have set the publisher account private key"
    );
  }

  const move = new cli.Move();

  // Perform the upgrade of the Move package
  try {
    const response = await move.upgradeObjectPackage({
      packageDirectoryPath: "contract",
      objectAddress: process.env.MODULE_ADDRESS,
      namedAddresses: {
        message_board_addr: process.env.MODULE_ADDRESS,
      },
      extraArguments: [
        `--private-key=${process.env.MODULE_PUBLISHER_ACCOUNT_PRIVATE_KEY}`,
        `--url=${aptosSDK.NetworkToNodeAPI[process.env.APP_NETWORK]}`,
      ],
    });

    console.log("Upgrade successful:", response);
  } catch (error) {
    console.error("Error upgrading package:", error);
  }
}

// Execute the upgrade function
upgrade();
