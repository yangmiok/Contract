//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "ITRC20.sol";
import "IAsgProfessionalManagers.sol";

interface IStarAwards {
    function withdrawalWithPermit(
        uint256 _txId, 
        address _account, 
        uint256 _amount,
        uint256 _deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) 
        external
        returns (bool success);

    event Withdrawal2(uint indexed txId, address indexed account, uint amount);
}


contract StarAwards is IStarAwards {

    address immutable ADMINISTRATORS;
    // keccak256("Withdrawal(uint256 txId,address account,uint256 amount,uint256 deadline)");
    bytes32 public immutable AGREE_TYPEHASH;
    bytes32 public immutable DOMAIN_SEPARATOR;
    mapping(uint => bool) isExecuted;

    struct Withdrawal{
        uint256 txId;
        address account;
        uint256 amount;
        uint256 deadline;
    }

    constructor(address _administrators) {
        ADMINISTRATORS = _administrators;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,address verifyingContract)"),
                keccak256(bytes("StarAwards")),
                keccak256(bytes('1')),
                address(this)
            )
        );

        AGREE_TYPEHASH = keccak256("Withdrawal(uint256 txId,address account,uint256 amount,uint256 deadline)");
    }

    function withdrawalWithPermit(
        uint256 _txId, 
        address _account, 
        uint256 _amount,
        uint256 _deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) 
        external
        override
        returns (bool success)
    {
        require(block.timestamp <= _deadline, "StarAwards: Signatures beyond the validity period");
        require(!isExecuted[_txId], "StarAwards: Orders have been executed");
        Withdrawal memory vc = Withdrawal({
            txId: _txId,
            account: _account,
            amount: _amount,
            deadline: _deadline
        });
        require(verify(vc, v, r, s), "StarAwards: Authentication failure");

        isExecuted[_txId] = true;
        address asgAddress = IAsgProfessionalManagers(ADMINISTRATORS).asgAddress();
        uint asgBalance = ITRC20(asgAddress).balanceOf(address(this));
        if (asgBalance < _amount) _amount = asgBalance;
        
        ITRC20(asgAddress).transfer(_account, _amount);
        emit Withdrawal2(_txId, _account, _amount);
        success = true;
    }

    function verify(Withdrawal memory vc,uint8 v,bytes32 r,bytes32 s) internal view returns (bool) {

        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(AGREE_TYPEHASH, vc.txId, vc.account, vc.amount,vc.deadline))
            )
        );
        return ecrecover(digest, v, r, s) == IAsgProfessionalManagers(ADMINISTRATORS).verifyAddress();
    }

   function test(
        uint256 _txId, 
        address _account, 
        uint256 _amount,
        uint256 _deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) 
        external
        view
        returns (address)
    {
        require(block.timestamp <= _deadline, "StarAwards: Signatures beyond the validity period");
        require(!isExecuted[_txId], "StarAwards: Orders have been executed");
        Withdrawal memory vc = Withdrawal({
            txId: _txId,
            account: _account,
            amount: _amount,
            deadline: _deadline
        });
         bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(AGREE_TYPEHASH, vc.txId, vc.account, vc.amount,vc.deadline))
            )
        );
        return ecrecover(digest, v, r, s);
    }
    
}