//SPDX-License-Identifier: MIT;
pragma solidity 0.8.6;

contract VerifySig {
  
  function verifyMessageToHex(address _signer, string memory _message, bytes memory _sig) external pure returns(bool) {
    bytes32 msg2 = keccak256(abi.encodePacked(
      "\x19TRON Signed Message:\n32",
      abi.encodePacked(_message)
    ));
    
    return recover(msg2, _sig) == _signer;
  }
  
  function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) internal pure returns(address){
    (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
    //v = v == 28 ? 1 : 0;
    return ecrecover(_ethSignedMessageHash, v, r, s);
  }
  
  function _split(bytes memory _sig) internal pure returns(bytes32 r, bytes32 s, uint8 v) {
    require(_sig.length == 65, "invalid signnature length");
    assembly {
      r := mload(add(_sig, 32))
      s := mload(add(_sig, 64))
      v := byte(0, mload(add(_sig, 96)))
    }
  }
}