import { Button, Card, DatePicker, Divider, Input, Progress, Slider, Spin, Switch } from "antd";
import React, { useState } from "react";
import { utils } from "ethers";
import { SyncOutlined } from "@ant-design/icons";

import { Address, Balance, Events, AddressInput } from "../components";

export default function CreateLeaderboard({
  purpose,
  address,
  mainnetProvider,
  localProvider,
  yourLocalBalance,
  price,
  tx,
  readContracts,
  writeContracts,
}) {
  const [projectID, setProjectID] = useState(0);
  const [leaderboardName, setLeaderboardName] = useState("");
  const [epoch, setEpoch] = useState(0);
  const [NFTRequired, setNFTRequired] = useState(0);

  return (
    <div>
      <div style={{ border: "1px solid #cccccc", padding: 16, width: 600, margin: "auto", marginTop: 64 }}>
        <h2>Register Project:</h2>
        <Divider />
        Your Address:
        <div style={{ marginLeft: 8 }}>
          <Address address={address} ensProvider={mainnetProvider} fontSize={16} />
        </div>
        <Divider />
        <div style={{ margin: 18 }}>
          <div style={{ marginBottom: 5 }}>
            Project ID: 
            <Input
              autoFocus
              placeholder="Enter project ID"
              onChange={(e) => { setProjectID(e.target.value) }}
            />
          </div>
          <div style={{ marginTop: 8, marginBottom: 5 }}>
            Leaderboard Name: 
            <Input
              autoFocus
              placeholder="Enter leaderboard name e.g. 'Best Meme Creator'"
              onChange={(e) => { setLeaderboardName(e.target.value) }}
            />
          </div> 
          <div style={{ marginTop: 8, marginBottom: 5 }}>
            Epoch (in days):
            <Input
              autoFocus
              placeholder="Enter how often the leaderboard resets"
              onChange={(e) => { setEpoch(e.target.value) }}
            />
          </div>
          <div style={{ marginTop: 8, marginBottom: 5 }}>
            # of NFT's Required to Vote:
            <Input
              autoFocus
              placeholder="Enter 1 or more"
              onChange={(e) => { setNFTRequired(e.target.value) }}
            />
          </div>
          <Button
            style={{ marginTop: 8 }}
            onClick={async () => {
              const result = tx(writeContracts.YourContract.createLeaderboardNftRequired(projectID, leaderboardName, epoch, NFTRequired), update => {
                console.log("📡 Transaction Update:", update);
                if (update && (update.status === "confirmed" || update.status === 1)) {
                  console.log(" 🍾 Transaction " + update.hash + " finished!");
                  console.log(
                    " ⛽️ " +
                      update.gasUsed +
                      "/" +
                      (update.gasLimit || update.gas) +
                      " @ " +
                      parseFloat(update.gasPrice) / 1000000000 +
                      " gwei",
                  );
                }
              });
              console.log("awaiting metamask/web3 confirm result...", result);
              console.log(await result);
            }}
          >
            Create Leaderboard
          </Button>
        </div>
        
      </div>

      {/*
        📑 Maybe display a list of events?
          (uncomment the event and emit line in YourContract.sol! )
      */}
      {/*}
      <Events
        contracts={readContracts}
        contractName="YourContract"
        eventName="SetPurpose"
        localProvider={localProvider}
        mainnetProvider={mainnetProvider}
        startBlock={1}
      />

      <div style={{ width: 600, margin: "auto", marginTop: 32, paddingBottom: 256 }}>
        <Card>
          Check out all the{" "}
          <a
            href="https://github.com/austintgriffith/scaffold-eth/tree/master/packages/react-app/src/components"
            target="_blank"
            rel="noopener noreferrer"
          >
            📦 components
          </a>
        </Card>

        <Card style={{ marginTop: 32 }}>
          <div>
            There are tons of generic components included from{" "}
            <a href="https://ant.design/components/overview/" target="_blank" rel="noopener noreferrer">
              🐜 ant.design
            </a>{" "}
            too!
          </div>

          <div style={{ marginTop: 8 }}>
            <Button type="primary">Buttons</Button>
          </div>

          <div style={{ marginTop: 8 }}>
            <SyncOutlined spin /> Icons
          </div>

          <div style={{ marginTop: 8 }}>
            Date Pickers?
            <div style={{ marginTop: 2 }}>
              <DatePicker onChange={() => {}} />
            </div>
          </div>

          <div style={{ marginTop: 32 }}>
            <Slider range defaultValue={[20, 50]} onChange={() => {}} />
          </div>

          <div style={{ marginTop: 32 }}>
            <Switch defaultChecked onChange={() => {}} />
          </div>

          <div style={{ marginTop: 32 }}>
            <Progress percent={50} status="active" />
          </div>

          <div style={{ marginTop: 32 }}>
            <Spin />
          </div>
        </Card>
      </div>
    */}
    </div>
  );
}
