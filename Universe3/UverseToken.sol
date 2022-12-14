// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ISpender {
    // function getRewardsPoolBalance() external view returns (uint256);
    function findVendorId(address _account) external view returns (uint256);
    // function withdrawProfit(address _to, uint256 _ammount ) external returns (bool);
    function checkIsVendor(address _account) external view returns (bool);
}
contract universeToken is ERC20, ERC20Burnable, Ownable {

// scale to 10,000.
//1 = 0.01%
// 10 = 0.1%
// 100 = 1%
// 1,000 = 10%
// 10,000 = 100%
// INTERFACE of spender

ISpender private SpendContract;

mapping (address => bool) public isMySpender;

function setSpender(ISpender _spender) public onlyOwner returns(bool) {
    isMySpender[address(_spender)] = !isMySpender[address(_spender)];
    SpendContract = _spender;
    return true;
}

 enum voteAction {
    upVote,
    downVote
}
 struct Vote {
     uint256 id;
     uint256 value;
     address voter;
     voteAction action;
     address vendor;
 }
  struct payout {
        uint256 payout_;
        bool overMax;
    }
 function checkIsVendor(address _vendor) public view returns(bool){
     return SpendContract.checkIsVendor(_vendor);

 } 
uint256 public decimalMultiplier = 10000;
uint256 maxReward = 2500; // remember to change back to 2%, currently 25%
uint256 public totalVotes = 0;
uint256 public totalNegativeVotes = 0;
uint256 public rewardTreshold = 1;

 
address [] public VotedVendors;
Vote[] public VoteList;
// mapping (address => bool) public isVendor;
mapping (address => bool) public isVoted;
mapping (address => bool) public isBanned;
mapping(address => bool) controllers;

//EVENTS
event voted(address voter, uint256 amount, address vendor, voteAction action);
event Claimed(address vendor, uint256 amount);

    // list of accounts that control this contract    
    constructor() ERC20("Universe", "UVT") payable {}

    function mint(address _account) external payable returns(bool) {
        // require that only the Spender contract address can mint new tokens
/////////////////////////////////////////////////////
        // require(address(msg.sender) == address(SpendContract),"out of bounds"); 
///////////////////////////////////////////////////////////////////////////////////////////////
        _mint(_account, 1); 
        return true;
    }

function decimals() public view virtual override returns (uint8) {
        return 1;
    }
function getTotalVotes() public view returns(uint256){
        return totalVotes;
}
function getNetTotalVotes() public view returns(uint256) {
        return SafeMath.sub(totalVotes,totalNegativeVotes);
}
function setRewardTreshold (uint256 _amount) public onlyOwner returns(bool){
       rewardTreshold = _amount;
       return true;
}
function checkIsVoted(address _account) public view returns (bool){
        return isVoted[_account];
}
function ban (address _account) public returns(bool){
    isBanned[_account] = !isBanned[_account];
    return true;
}
function setMaxReward(uint256 _amount) public onlyOwner returns(bool){
    maxReward = _amount;
    return true;
}


// BUGGGGGGGGGGGGG note that when a user votes no, 2 tokens get burnt out of circulation not one
// Note one downvote is worth twice as much as an upvote because two tokens get burnt
function VoteForVendor(uint256 _ammount, voteAction _vote, address _vendor) public payable returns (bool) {
    // IMPROVEMENT // require vendor has had transactions already.
    require(SpendContract.checkIsVendor(_vendor), "not a vendor");
    require(address(msg.sender) != _vendor,"cannot vote yourself");
    uint256 newVote = VoteList.length +1;
    voteAction  _voteAction;
    _burn(address(msg.sender), _ammount);
    totalVotes += _ammount; //// Note one downvote is worth twice as much as an upvote because two tokens get burnt
if (_vote == _voteAction) {
       _mint(address(_vendor), _ammount);
        } 
else{

    if(balanceOf(_vendor) - _ammount < 0){
    _burn(address(_vendor), balanceOf(_vendor));
    totalNegativeVotes +=_ammount;
    } else{
    _burn(address(_vendor), _ammount);
    totalNegativeVotes +=_ammount;
    } 
}
    // check if isVoted
if (isVoted[_vendor]){
    VotedVendors.push(address(_vendor));
    VoteList.push(Vote({
    id: newVote,
    value: _ammount,
    voter: msg.sender,
    action: _vote,
    vendor: _vendor
    }));
    emit voted(msg.sender, _ammount, _vendor, _vote);
    return (true);
} else {
    isVoted[_vendor] = !isVoted[_vendor];
    VotedVendors.push(address(_vendor));
     VoteList.push(Vote({
     id: newVote,
    value: _ammount,
     voter: msg.sender,
     action: _vote,
     vendor: _vendor
    }));
    emit voted(msg.sender, _ammount, _vendor, _vote);
    return (true);
        }
}

function ResetContest () public onlyOwner returns(bool){
totalVotes = 0;
totalNegativeVotes = 0;

for(uint i =0; i < VotedVendors.length; i++){
   delete VotedVendors[i];
   isBanned[VotedVendors[i]] = false;
}
for(uint i =0; i < VoteList.length; i++){
   delete VoteList[i];
}
       return true;
   }

}