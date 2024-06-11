const hre = require('hardhat');
const { run } = require('hardhat');

async function verify(address, constructorArguments) {
    console.log(`verify  ${address} with arguments ${constructorArguments.join(',')}`);
    await run('verify:verify', {
        address,
        constructorArguments
    });
}
async function main() {
    const signer = process.env.SIGNER;

    const Claims = await hre.ethers.deployContract('Claims', [signer]);
    console.log('Deploying Claims...');
    await Claims.waitForDeployment();
    console.log('Claims deployed to:', Claims.target);
    await new Promise((resolve) => setTimeout(resolve, 20000));
    verify(Claims.target, [signer]);
}

main();