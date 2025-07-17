let web3;
let contract;
let account;
const contractAddress = "0x66775a34E23Dc3CF8C2722011b314f2004416405";
const contractABI = [
    /* ABI goes here */
]; 

function $(id) {
    return document.getElementById(id);
}

const $status = $("status");

window.addEventListener("DOMContentLoaded", async () => {
    if (window.ethereum) {
        web3 = new Web3(window.ethereum);

        $status.textContent = "MetaMask detected. Trying to connect.";
        try {
            const accounts = await window.ethereum.request({
                method: "eth_requestAccounts",
            });
            // Choose the first account for now
            account = accounts[0]
            $status.textContent = `Connected wallet: ${account}`;

            contract = new web3.eth.Contract(contractABI, contractAddress);

            $("buyBtn").addEventListener("click", buyCredit);
            $("retireBtn").addEventListener("click", retireCredit);
        } catch (err) {
            alert(err);
            $status.textContent = "Error with MetaMask connection.";
        }
    } else {
        $status.innerHTML =
            "Please <a href='https://metamask.io/download/'>install MetaMask</a>.";
    }
});

async function buyCredit() {
    // Boiler plate code until I get the ABI
    const amount = $("carbonAmount").value;
    try {
        const cost = await contract.methods
            .calculateCost(amount)
            .call();
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
        await contract.methods
            .retire(amount)
            .send({ from: account });
        alert(`Retired ${amount} carbon credits!`);
    } catch (err) {
        alert(`Error: ${err.message}`);
    }
}
