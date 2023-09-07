const ethSigUtils = require("@metamask/eth-sig-util");

const ethUtil = require("ethereumjs-util");

const SingData = () => {
    const [privateStr, name, verifyingContract, txId, account, amount, deadline] = process.argv.slice(2);
    console.log(privateStr, name, verifyingContract, txId, account, amount, deadline);
    const signParams = {
        types: {
            EIP712Domain: [
                { name: "name", type: "string" },
                { name: "version", type: "string" },
                { name: "verifyingContract", type: "address" },
            ],
            Withdrawal: [
                { name: "txId", type: "uint256" },
                { name: "account", type: "address" },
                { name: "amount", type: "uint256" },
                { name: "deadline", type: "uint256" },
            ],
        },
        primaryType: "Withdrawal",
        domain: {
            name,
            version: "1",
            verifyingContract,
        },
        message: {
            txId,
            account,
            amount,
            deadline,
        },
    };
    console.log(signParams);
    const hash = ethSigUtils.TypedDataUtils.eip712Hash(
        signParams,
        ethSigUtils.SignTypedDataVersion.V4
    );
    console.log(hash);
    const sign = ethUtil.ecsign(hash, ethUtil.toBuffer(privateStr));
    return {
        r: "0x" + sign.r.toString("hex"),
        s: sign.s.toString("hex"),
        v: sign.v,
    };
};
console.log(JSON.stringify(SingData()));