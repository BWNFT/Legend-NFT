// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Auth.sol";
import "./ERC721.sol";

interface ApproveAndCallFallBack {
    function receiveApproval(address to, uint256 tokenId, address token, bytes calldata extraData) external returns(bool);
}

contract ERC721Token is ERC721, Auth {
    using Strings for uint256;
    
    string private _baseTokenURI;
    mapping(uint256 => string) private _tokenURIs;
    
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        
    }
    
    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        require(_exists(tokenId), "ERC721: ERC721Metadata URI query for nonexistent token");
        string memory uri = bytes(_tokenURIs[tokenId]).length > 0 ? _tokenURIs[tokenId] : tokenId.toString();
        return bytes(_baseTokenURI).length > 0 ? string(abi.encodePacked(_baseTokenURI,uri)) : uri;
    }
    
    function setBaseURI(string memory newBaseTokenURI) external onlyAuth {
        _baseTokenURI = newBaseTokenURI;
    }
    
    function setTokenURI(uint256 tokenId, string memory _tokenURI) external onlyAuth {
        require(_exists(tokenId), "ERC721: ERC721URIStorage URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
    
    function mint(address to, uint256 tokenId) external onlyAuth {
        _mint(to,tokenId);
    }
    
    function safeMint(address to, uint256 tokenId) external onlyAuth {
        _safeMint(to, tokenId);
    }
    
    function safeMint(address to,uint256 tokenId,bytes memory _data) external onlyAuth {
        _safeMint(to, tokenId, _data);
    }
    
    function burn(uint256 tokenId) external onlyAuth {
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
        _burn(tokenId);
    }
    
    function approveAndCall(address to, uint256 tokenId, bytes calldata extraData) external returns (bool) {
        approve(to,tokenId);
        if(!ApproveAndCallFallBack(to).receiveApproval(msg.sender, tokenId, address(this), extraData)){
            revert("ERC721: approveAndCall Execution failed");
        }
        return true;
    }
}
