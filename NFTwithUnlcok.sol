// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./IPublicLock.sol";



contract DemoNFT is  ERC1155, Ownable {

  constructor(IPublicLock _lockAddress) ERC1155("") 
  {
    lock = _lockAddress;
  }
    uint indexOfNft = 0;
   IPublicLock public lock;
    
    
    
    struct User {
        string name;
        string lastName;
        uint8 level;
        uint xp;
        string imageUri;
        uint threshold;
    
    }

    uint public identifyXP;
    bool public access = false;

    event customEvent(address indexed _sender, uint indexed _xp);

    User[] public users;
    mapping(uint => address) public ownerOfNft;
    mapping(address => uint) public nftOfOwner;


    function _toGetXpInfo(address _toGetXP) external {
        uint _user = nftOfOwner[_toGetXP];
        emit customEvent(_toGetXP, users[_user].xp);

        identifyXP = users[_user].xp;
    }

    function _toGetAccessToSyntaxGenerator(address _toGetAccess) external returns (bool _access) {
        require(users[nftOfOwner[_toGetAccess]].level > 2, "Level is low");
        access = true;
        return access;
    }


    function setUser(string memory _name, string memory _lastName, string memory _imageUri) external {
     require(lock.balanceOf(msg.sender) > 0, 'Purchase a membership first!');
        users.push(User(_name, _lastName, 1, 0, _imageUri, 100));
        ownerOfNft[indexOfNft] = msg.sender;
        nftOfOwner[msg.sender] = indexOfNft;
        indexOfNft++;
    }

    function levelUp(uint ownerOfNftId) external payable {
        require(msg.value >= 0.01 ether);
        users[ownerOfNftId].level++;
        users[ownerOfNftId].threshold = users[ownerOfNftId].threshold * 3 / 2;
        users[ownerOfNftId].xp = users[ownerOfNftId].threshold;
    }

    function levelUpByXp(uint ownerOfNftId) private {
        if(users[ownerOfNftId].xp >= users[ownerOfNftId].threshold) {
        users[ownerOfNftId].level++;
        users[ownerOfNftId].threshold = users[ownerOfNftId].threshold * 3 / 2;
        } 
    }

    function gainXP() public {
        users[nftOfOwner[msg.sender]].xp += 100;
        levelUpByXp(nftOfOwner[msg.sender]);
    }


   

    function setImageURI(string memory _imgUri) external {
        if(users[nftOfOwner[msg.sender]].level > 5) {
            users[nftOfOwner[msg.sender]].imageUri = _imgUri;
        }
    }

    function withdraw() public onlyOwner {        
         uint amount = address(this).balance;         
          (bool success, ) = msg.sender.call{value: amount}("");        
           require(success, "Failed to withdraw");   
            }     
    function transferNft(uint nftId, address newOwner) public returns (bool) {        
            require(ownerOfNft[nftId] == msg.sender);        
            ownerOfNft[nftId] = newOwner;        
            nftOfOwner[newOwner] = nftId;         
             return true;    
            }
}
