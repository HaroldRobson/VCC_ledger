let web3;
let account;

let factoryContract;
let pools;

function $(id) {
    return document.getElementById(id);
}

const $status = $("status");

function formatDate(timestamp) {
    if (!timestamp) return "N/A";
    const tsNumber = Number(timestamp);

    if (isNaN(tsNumber) || tsNumber <= 0) return "N/A";

    return new Date(tsNumber * 1000).toLocaleString();
}

window.addEventListener("DOMContentLoaded", async () => {
    if (window.ethereum) {
        await main();
    } else {
        $status.innerHTML =
            "Please <a href='https://metamask.io/download/'>install MetaMask</a>.";
    }
});

async function main() {
    web3 = new Web3(window.ethereum);
    $status.textContent = "MetaMask detected. Trying to connect.";

    try {
        const accounts = await window.ethereum.request({
            method: "eth_requestAccounts",
        });
        // Choose the first account for now
        account = accounts[0];
        $status.textContent = `Connected wallet: ${account}`;

        try {
            await initFactory();
        } catch (err) {
            console.error(err);
        }

        $("menu").classList.add("visible");

        $("buyBtn").addEventListener("click", buyCredit);
        $("retireBtn").addEventListener("click", retireCredit);
    } catch (err) {
        console.error(err);
        $status.textContent = "Error with MetaMask connection.";
    }
}

async function initFactory() {
    factoryContract = new web3.eth.Contract(factoryABI, factoryAddress);
    console.log("made factory contract");
    const poolCount = await factoryContract.methods.counter().call();
    console.log(`Factory has created ${poolCount} pools`);

    pools = [];

    // Loop through all pools by index
    for (let i = 0; i < poolCount; i++) {
        const pool = await factoryContract.methods.pools(i).call();
        pools.push(pool);
        const cbxContract = new web3.eth.Contract(cbxABI, pool.poolAddress);

        // For example, call some CBX method:
        // const someValue = await cbxContract.methods.someMethod().call();

        console.log(`Pool ${i}:`, {
            serialNumber: pool.serialNumber,
            poolAddress: pool.poolAddress,
            countryOfOrigin: pool.countryOfOrigin,
            methodologies: pool.methodologies,
            issuanceDate: pool.issuanceDate,
            createdAt: pool.createdAt,
        });
    }

    await displayPools();
}

async function displayPools() {
    const container = $("pools");
    container.innerHTML = ""; // Clear any existing content

    for (let i = 0; i < pools.length; i++) {
        const pool = pools[i];
        const poolDiv = document.createElement("div");
        const cbxContract = new web3.eth.Contract(cbxABI, pool.poolAddress);
        const pricePerToken = await cbxContract.methods.pricePerToken().call(); 

        poolDiv.className = "pool";

        poolDiv.innerHTML = `
          <h3>Pool ${i + 1}: ${pool.serialNumber}</h3>
          <div>Country of Origin: ${pool.countryOfOrigin}</div>
          <div>Methodologies: ${pool.methodologies}</div>
          <div>Issuance Date: ${formatDate(pool.issuanceDate)}</div>
          <div>Created At: ${formatDate(pool.createdAt)}</div>
          <div>Pool Address: ${pool.poolAddress}</div>
          <div>Price per token: ${pricePerToken}</div>
        `;

        container.appendChild(poolDiv);
    }
}

async function buyCredit() {
    // Boiler plate code until I get the ABI
    const amount = $("carbonAmount").value;
    try {
        const cost = await contract.methods.calculateCost(amount).call();
        await contract.methods.buy(amount).send({
            from: account,
            value: cost,
        });
        alert(`Bought ${amount} carbon credits!`);
    } catch (err) {
        alert(`Error: ${err.message}`);
    }
}

async function retireCredit() {
    // Boiler plate code until I get the ABI
    const amount = $("carbonAmount").value;
    try {
        await contract.methods.retire(amount).send({ from: account });
        alert(`Retired ${amount} carbon credits!`);
    } catch (err) {
        alert(`Error: ${err.message}`);
    }
}

