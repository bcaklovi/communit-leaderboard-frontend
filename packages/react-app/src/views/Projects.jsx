import { Button, Card, DatePicker, Divider, Input, Progress, Slider, Spin, Switch } from "antd";
import React, { useState, useEffect } from "react";
import { utils } from "ethers";
import { SyncOutlined } from "@ant-design/icons";
import {
  useBalance,
  useContractLoader,
  useContractReader,
  useGasPrice,
  useOnBlock,
  useUserProviderAndSigner,
} from "eth-hooks";
import { Address, Balance, Events, AddressInput } from "../components";

export default function Projects({
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

  const [projectCount, setProjectCount] = useState();
  const [projects, setProjects] = useState([]);

  //const projectCount = useContractReader(readContracts, "YourContract", "projectCount");

  useEffect(() => {
    getProjectCount();
  }, []);

  useEffect(() => {
    getProjects(projectCount);
  }, [projectCount])

  const getProjectCount = async () => {
    let result = await readContracts.YourContract.getProjectCount();
    result = result.toNumber();
    setProjectCount(result);
  }

  /*
  const getProjects = async (total) => {
    for (let i = 0; i < total; i++) {
      const result = await readContracts.YourContract.getProjectName(i);
      if (!(projects.includes(result))) {
        setProjects(prev =>  [...prev, result]);
        console.log(projects);
      }
    }
  } */

  const getProjects = async (total) => {
    for (let i = 0; i < total; i++) {
      const name = await readContracts.YourContract.getProjectName(i);
      const leaderboardCount = await readContracts.YourContract.getProjectLeaderboardCount(i);
      const project = {
        name: name,
        leaderboardCount: leaderboardCount.toNumber()
      }
      if (!projects.includes(project)) {
        setProjects(prev => [...prev, project]);
        console.log(projects);
      }
    }
  }

  return (
    <div>
      <div style={{ border: "1px solid #cccccc", padding: 16, width: 600, margin: "auto", marginTop: 64 }}>
        {projects && projects.map((project, index) => (
          <div key={index}>
            <div>
              Name: {project.name}
            </div>
            <div>
              Number of Leaderboards: {project.leaderboardCount}
            </div>
          </div>
        ))}
      </div>

      <Button
        style={{ marginTop: 8 }}
        onClick={async () => {
          const result = readContracts.YourContract.getProjectName(0);
          console.log("awaiting metamask/web3 confirm result...", result);
          console.log(await result);
        }}
      >
        Test get project name
      </Button>
    </div>
  );
}
