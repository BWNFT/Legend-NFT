// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAuthority {
    function canCall(address src, address dst, bytes4 sig) external view returns (bool);
}

contract Auth {
    address private _owner;
    address private _authority;
    
    event SetOwner (address indexed owner);
    event SetAuthority(address indexed authority);

    constructor() {
        _owner = msg.sender;
        emit SetOwner(msg.sender);
    }
    
    function ownerOf() external view returns (address) {
        return _owner;
    }
    
    function authorityOf() external view returns (address) {
        return _authority;
    }
    
    function setOwner(address owner) external onlyAuth {
        _owner = owner;
        emit SetOwner(_owner);
    }

    function setAuthority(address authority) external onlyAuth {
        _authority = authority;
        emit SetAuthority(_authority);
    }
    
    modifier onlyAuth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == _owner) {
            return true;
        } else if (_authority == address(0)) {
            return false;
        } else {
            return IAuthority(_authority).canCall(src, address(this), sig);
        }
    }
}