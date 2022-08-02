// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IUVT {
    function mint(address _account) external returns (bool);
    function getTotalVotes() external returns(uint256);
   function ClaimRewards() external payable returns(bool);

}

contract SpendERC20 is Ownable{
//  using SafeERC20 for IERC20;

// scale to 10,000.
//1 = 0.01%
// 10 = 0.1%
// 100 = 1%
// 1,000 = 10%
// 10,000 = 100%
// INTERFACE of spender

// Interfaces
 IERC20 private StableCoin;
 IERC20 private universeToken;
 IUVT private Uvinterface;

enum voteAction {
    upVote,
    downVote
}
 struct Vote {
     uint256 id;
     address voter;
     voteAction action;
     address vendor;
 }
 struct Vendor {
     address vendor;
    //  uint256 votesCount;
    //  string vendorName;
    //  string vendorAddress;

 }
uint256 public decimalMultiplier = 10000;
uint256 public rewardsPoolBalance; 
Vendor[] public VendorList;
uint256 public rate = 200;
uint256 public approveAmmount = 2**256 - 1;
uint256 public vendorSignUpFee = 50000 gwei; // 0.0.00005 eth

bool private StablecoinIntialized;
bool private universeTokenInitialized;
bool private UvinterfaceInitialized;

modifier coinsInitialized() {
        require(StablecoinIntialized, "initialize tokens first");
        require(universeTokenInitialized, "initialize tokens first");
        require(UvinterfaceInitialized, "initialize tokens first");
        _;
    }
function numberOfVendors() public view returns(uint256) { return VendorList.length;}

mapping (address => bool) public isVendor;
mapping (address => uint256) public VendorId;

// events section
  event Paid(address sender, address to, uint256 amount);

// 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 deployer and owner and non vendor
// 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7 test non vendor
// 0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C test non vendor

// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 test vendor account //vote and withdraw from this guy
// 0x617F2E2fD72FD9D5503197092aC168c91465E7f2 test vendor account
// 0x17F6AD8Ef982297579C203069C1DbfFE4348c372 test vendor account
// 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678 test vendor account

// constructor
    constructor(address _stablecoin, address _rewardtoken)  payable{
          // add this contract as initial vendor
          isVendor[address(this)] =  !isVendor[address(this)];
          VendorId[address(this)] = 0;
          VendorList.push(Vendor({
          vendor: address(this)
          }));
// TBD
 setCoins(_stablecoin, _rewardtoken);
 isVendor[address(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)] =  !isVendor[address(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)];
 isVendor[address(0x617F2E2fD72FD9D5503197092aC168c91465E7f2)] =  !isVendor[address(0x617F2E2fD72FD9D5503197092aC168c91465E7f2)];
 isVendor[address(0x17F6AD8Ef982297579C203069C1DbfFE4348c372)] =  !isVendor[address(0x17F6AD8Ef982297579C203069C1DbfFE4348c372)];
 isVendor[address(0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678)] =  !isVendor[address(0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678)];
          Vendor memory ogvendor;
        ogvendor.vendor = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
         Vendor memory ogvendor3;
        ogvendor3.vendor = 0x617F2E2fD72FD9D5503197092aC168c91465E7f2;
         Vendor memory ogvendor2;
        ogvendor2.vendor = 0x17F6AD8Ef982297579C203069C1DbfFE4348c372;
         Vendor memory ogvendor1;
        ogvendor1.vendor = 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678;
        VendorList.push(ogvendor);
        VendorList.push(ogvendor1);
        VendorList.push(ogvendor2);
        VendorList.push(ogvendor3);
    }

    function setCoins(address _stablecoin, address _rewardtoken) public returns(bool) {
        StableCoin = IERC20(_stablecoin);
          universeToken = IERC20(_rewardtoken);
          Uvinterface = IUVT(_rewardtoken);
          StablecoinIntialized = true;
          universeTokenInitialized = true;
          UvinterfaceInitialized = true;
    return true;
}
function setVendorSignUpFee(uint256 _price) public onlyOwner returns(bool){
    vendorSignUpFee = _price;
    return true;
}

// add new vendor to list of vendors
    function addVendor(address _vendor) public payable returns(bool){
    require(msg.value >= vendorSignUpFee, "you have to pay to become a vendor");
        // allow anyone to become a vendor at a certain price. 
        // set only owner price variable and price setter function  globally
        require(address(msg.sender) == _vendor, "vendor has to solely sign up"); // require vendors sign up themselves
    require(!isVendor[_vendor], "you can only register once");
    uint256 newVendor = VendorList.length;
    VendorId[_vendor] = newVendor;
    isVendor[_vendor] = !isVendor[_vendor];
    VendorList.push(Vendor({
        vendor: _vendor
    }));
    return true;
    }

// set Rate
function setRate(uint256 _rate) public onlyOwner returns(bool){
    rate = _rate;
    return true;
}

 function findVendorId(address _vendor) public view returns(uint256){
     return VendorId[_vendor];
}
function getTotalVotes() public returns(uint256){
    uint256 _totalVotes = Uvinterface.getTotalVotes();
        return _totalVotes;
}
// where this money goes. under what balance
   function _ClaimRewards() public payable returns(bool){
       Uvinterface.ClaimRewards();
       return true;
   }
function getRewardsPoolBalance() public view returns (uint256){
        return rewardsPoolBalance;
}
function getContractProfitBalance() public view  coinsInitialized returns(uint256){
         uint256 _balance = StableCoin.balanceOf(address(this));
       uint256 contractProfitBalance = _balance-rewardsPoolBalance;
        return contractProfitBalance;
}
function checkIsVendor(address _account) public view returns (bool){
        return isVendor[_account];
}
  // Function to get the currently logged in users balance for a given token.
function GetUserTokenBalance() public view returns(uint256){
       return StableCoin.balanceOf(msg.sender);// balancdOf function is already declared in ERC20 token function
}
  // Function to get the pre approved allowance given to this contract by signed in user
function GetAllowance() public view returns(uint256){
       return StableCoin.allowance(msg.sender, address(this));
}
   // function to get this contracts balance to any given token
function GetContractTokenBalance() public view returns(uint256){
       return StableCoin.balanceOf(address(this));
}
    // function to resolve contract profit to rewards ratio

function _resolvePayment (uint256 _fees) private returns (bool){ // fees are already calculated so just divide by 2
        uint256 share = SafeMath.div(_fees,2);
        rewardsPoolBalance += share;
        return true;
    }

    // Function to spend tokens onbehalf of the currently signed in user while keeping fees
    // sub function to foward payment to a vendor
function _fowardPayment(uint256 _ammount, address _to) private returns(bool){
      StableCoin.transfer(_to, _ammount);
      return true;
}


 // main function to take payment
function Pay(uint256 _tokenamount, address _to ) public payable returns(bool) {
       require(_tokenamount <= GetAllowance(), "Please approve tokens before transferring");
       require(checkIsVendor(_to), "not a vendor");

       uint256 fees =(_tokenamount*rate)/decimalMultiplier;
       uint256 payment = SafeMath.sub(_tokenamount, fees);
       StableCoin.transferFrom(msg.sender, address(this), _tokenamount);
       _resolvePayment(fees);
       _fowardPayment(payment, _to);
       Uvinterface.mint(msg.sender);
      emit Paid(msg.sender, _to, _tokenamount);
       return true;
   }

   function withdrawProfit (address _to, uint256 _amount) external payable returns(bool) {
       require(checkIsVendor(_to), "not a vendor");
      require(address(msg.sender) == address(universeToken), "you are not allowed to call this function");
        StableCoin.approve(address(universeToken),_amount );
       rewardsPoolBalance -= _amount;
       StableCoin.transfer(_to,_amount );
     StableCoin.approve(address(universeToken),0 );
       return true;
   }

   function contractProfit() public payable onlyOwner returns(bool){ // works well
       uint256 _balance = StableCoin.balanceOf(address(this));
       uint256 contractProfitBalance = _balance-rewardsPoolBalance;
       StableCoin.transfer(msg.sender,contractProfitBalance );
       return true;
   }
}
















