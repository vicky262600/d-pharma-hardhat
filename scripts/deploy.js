const { ethers, run, network } = require("hardhat");

async function main(){
    const dPharma = await ethers.getContractFactory("dPharma");

    console.log("deploying...");
    const pharmaInstance = await dPharma.deploy();

    await pharmaInstance.waitForDeployment();
    console.log(pharmaInstance.target);
}

main().then(()=>process.exit(0)).catch((error)=>{
    console.error(error);
    process.exit(1);
})