// scripts/publish.js

require("dotenv").config();
const fs = require("node:fs");
const cli = require("@aptos-labs/ts-sdk/dist/common/cli/index.js");
const aptosSDK = require("@aptos-labs/ts-sdk");

async function publish() {
  if (!process.env.MODULE_PUBLISHER_ACCOUNT_ADDRESS) {
    throw new Error(
      "MODULE_PUBLISHER_ACCOUNT_ADDRESS variable is not set, make sure you have set the publisher account address"
    );
  }

  if (!process.env.MODULE_PUBLISHER_ACCOUNT_PRIVATE_KEY) {
    throw new Error(
      "MODULE_PUBLISHER_ACCOUNT_PRIVATE_KEY variable is not set, make sure you have set the publisher account private key"
    );
  }

  const move = new cli.Move();

  move
    .createObjectAndPublishPackage({
      packageDirectoryPath: "contract",
      addressName: "message_board_addr",
      namedAddresses: {
        message_board_addr: process.env.MODULE_PUBLISHER_ACCOUNT_ADDRESS,
      },
      extraArguments: [
        `--private-key=${process.env.MODULE_PUBLISHER_ACCOUNT_PRIVATE_KEY}`,
        `--url=${aptosSDK.NetworkToNodeAPI[process.env.APP_NETWORK]}`,
      ],
    })
    .then((response) => {
      const filePath = ".env";
      let envContent = "";

      if (fs.existsSync(filePath)) {
        envContent = fs.readFileSync(filePath, "utf8");
      }

      const regex = /^MODULE_ADDRESS=.*$/m;
      const newEntry = `MODULE_ADDRESS=${response.objectAddress}`;

      if (envContent.match(regex)) {
        envContent = envContent.replace(regex, newEntry);
      } else {
        envContent += `\n${newEntry}`;
      }

      fs.writeFileSync(filePath, envContent, "utf8");
    });
}

publish();
