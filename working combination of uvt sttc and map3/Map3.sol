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

interface IWETH is IERC20 {
    function deposit() external payable;
}


contract Map3Pay is Ownable{
//  using SafeERC20 for IERC20;

// scale to 10,000.
//1 = 0.01%
// 10 = 0.1%
// 100 = 1%
// 1,000 = 10%
// 10,000 = 100%
// INTERFACE of spender

// Interfaces
 IERC20 private StableCoinInterface;
 IERC20 private universeToken;
 IUVT private Uvinterface;
IWETH public  WETH;

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

    uint256 private counter;

 struct Vendor {
    address vendorsWalletAddress;
    string vendorsName;
    string vendorsPhone;
    string vendorsBio;
    string vendorsLat;
    string vendorsLong;
    string vendorsImageUrl;
    string vendorsWebsiteUrl;
    uint256 vendorsId;
    IERC20 vendorsToken;
    //  uint256 votesCount;

 }

struct signUpVendor{
    address vendorsWalletAddress;
    string vendorsName;
    string vendorsStreetAddress;// Note street city state and zip only goes to events when vendor is created
    string vendorsCity;// Note city state and zip only goes to events when vendor is created
    string vendorsState;// Note city state and zip only goes to events when vendor is created
    string vendorsZip;// Note city state and zip only goes to events when vendor is created
    string vendorsPhone;
    string vendorsBio;
    string vendorsLat;
    string vendorsLong;
    string vendorsImageUrl;
    string vendorsWebsiteUrl;
    IERC20 vendorsToken;
}

event VendorCreated (
    address vendorsWalletAddress,
    string vendorsName,
    string vendorsStreetAddress,
    string vendorsCity,
    string vendorsState,
    string vendorsZip,
    string vendorsPhone
);
event newVendorInfo(
    string vendorsBio,
    string vendorsLat,
    string vendorsLong,
    string vendorsImageUrl,
    string vendorsWebsiteUrl,
    uint256 vendorsId,
    IERC20 vendorsToken
    );
     event MoneySpent (
        address from,
        address to,
        address tokenIn ,
        address tokenOut,
        uint256 amount
    );
    function addVendor(signUpVendor memory _signUpVendor) public payable returns(bool) {
    require(msg.value >= vendorSignUpFee, "you have to pay to become a vendor");
    require(address(msg.sender) == _signUpVendor.vendorsWalletAddress, "vendor has to solely sign up"); // require vendors sign up themselves
    require(!isVendor[_signUpVendor.vendorsWalletAddress], "you can only register once");

    isVendor[_signUpVendor.vendorsWalletAddress] = !isVendor[_signUpVendor.vendorsWalletAddress];

    VendorList.push(Vendor({
        vendorsWalletAddress: address(msg.sender),
        vendorsName: _signUpVendor.vendorsName,
        vendorsPhone: _signUpVendor.vendorsPhone,
        vendorsBio: _signUpVendor.vendorsBio,
        vendorsLat: _signUpVendor.vendorsLat,
        vendorsLong: _signUpVendor.vendorsLong,
        vendorsImageUrl: _signUpVendor.vendorsImageUrl,
        vendorsWebsiteUrl: _signUpVendor.vendorsWebsiteUrl,
        vendorsId: VendorId,
        vendorsToken: _signUpVendor.vendorsToken
    }));
    emit VendorCreated(
    _signUpVendor.vendorsWalletAddress,
    _signUpVendor.vendorsName,
    _signUpVendor.vendorsStreetAddress,
    _signUpVendor.vendorsCity,
    _signUpVendor.vendorsState,
    _signUpVendor.vendorsZip,
    _signUpVendor.vendorsPhone
    );
    emit newVendorInfo(
    _signUpVendor.vendorsBio,
    _signUpVendor.vendorsLat,
    _signUpVendor.vendorsLong,
    _signUpVendor.vendorsImageUrl,
    _signUpVendor.vendorsWebsiteUrl,
    VendorId,
    _signUpVendor.vendorsToken
        );
    VendorId ++;
    return true;

    }

uint256 public decimalMultiplier = 10000;
uint256 public rewardsPoolBalance;
uint256 public VendorId = 0;
Vendor[] public VendorList;
IERC20[] public StableTokenList;
IERC20 private _StableCoin;
uint256 public rate = 200; // currently 2%
uint256 public approveAmmount = 2**256 - 1;
uint256 public vendorSignUpFee = 0 gwei; // 0.0.00005 eth
// uint256 public vendorSignUpFee = 50000 gwei; // 0.0.00005 eth

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
 function AddStableCoin(IERC20 i) public onlyOwner { StableTokenList.push(i);}
 function removeStableCoin(uint i) public onlyOwner { delete StableTokenList[i];}
    

mapping (address => bool) public isVendor;
// mapping (address => uint256) public VendorId;

// events section
  event Paid(address sender, address to, uint256 amount);
    event FilledSwapOrder(IERC20 sellToken, IERC20 buyToken, uint256 boughtAmount);


    constructor(address _stablecoin, address _rewardtoken, address _weth)  payable{
          // add this contract as initial vendor

        _StableCoin = IERC20(_stablecoin);
          isVendor[address(this)] =  !isVendor[address(this)];
          VendorList.push(Vendor({

        vendorsWalletAddress: address(this),
        vendorsName: "Map3.0 MVP",
        vendorsPhone: "123-456-7890",
        vendorsBio: "Connect vendors in map3.0",
        vendorsLat: "40.716862",
        vendorsLong: "-73.999005",
        vendorsImageUrl: "https://ipfs.moralis.io:2053/ipfs/QmS3gdXVcjM72JSGH82ZEvu4D7nS6sYhbi5YyCw8u8z4pE/media/3",
        vendorsWebsiteUrl: "https://github.com/Erriccc",
        vendorsId: VendorId,
        vendorsToken: _StableCoin
          }));
    VendorId ++;

// TBD
        setCoins(_stablecoin, _rewardtoken, _weth);
          emit VendorCreated(

        address(this),
        "Map3.0 MVP",
        "Living on cloud 9",
        "City",
        "State",
        "60622",
        "123-456-7890"
          );
          emit newVendorInfo(
        "Connect vendors in map3.0",
        "40.716862",
        "-73.999005",
        "https://ipfs.moralis.io:2053/ipfs/QmS3gdXVcjM72JSGH82ZEvu4D7nS6sYhbi5YyCw8u8z4pE/media/3",
        "https://github.com/Erriccc",
        0,
        _StableCoin
        );
    }


    function setCoins(address _stablecoin, address _rewardtoken, address _weth) public returns(bool) {
          WETH = IWETH(_weth);
          StableCoinInterface = IERC20(_stablecoin);
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


// set Rate
function setRate(uint256 _rate) public onlyOwner returns(bool){
    rate = _rate;
    return true;
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
         uint256 _balance = StableCoinInterface.balanceOf(address(this));
       uint256 contractProfitBalance = _balance-rewardsPoolBalance;
        return contractProfitBalance;
}
function checkIsVendor(address _account) public view returns (bool){
        return isVendor[_account];
}
  // Function to get the pre approved allowance given to this contract by signed in user
function GetThisContractAllowance(IERC20 _Coin) public view returns(uint256){
       return _Coin.allowance(msg.sender, address(this));
}
function GetAllowance(IERC20 _Coin, address _account) public view returns(uint256){
       return _Coin.allowance(msg.sender, _account);
}
   // function to get this contracts balance to any given token
function GetContractTokenBalance() public view returns(uint256){
       return StableCoinInterface.balanceOf(address(this));
}
    // function to resolve contract profit to rewards ratio
function _resolvePayment (uint256 _fees) private returns (bool){ // fees are already calculated so just divide by 2
        uint256 share = SafeMath.div(_fees,2);
        rewardsPoolBalance += share;
        return true;
    }

    // Function to spend tokens onbehalf of the currently signed in user while keeping fees
    // sub function to foward payment to a vendor
function _fowardPayment(uint256 _ammount, address _to, IERC20 _tokenIn) private returns(bool){
      _tokenIn.transfer(_to, _ammount);
      return true;
}

    // This is the new Pay function
function SameTokenPay(uint256 _tokenamount, address _to, IERC20 _tokenIn)
 public payable returns(bool) {
       IERC20 _PayStableCoin = IERC20(_tokenIn);
       require(_tokenamount <= GetThisContractAllowance(_PayStableCoin), "Please approve enough tokens before transferring");
    if(checkIsVendor(_to)){
                // send feeless transactions
            _PayStableCoin.transferFrom(msg.sender,_to , _tokenamount);
            Uvinterface.mint(msg.sender);
            emit Paid(msg.sender, _to, _tokenamount);
            return true;
    }else{
                // send payment with percentage fees processed
            uint256 fees =(_tokenamount*rate)/decimalMultiplier;
            uint256 payment = SafeMath.sub(_tokenamount, fees);
            _PayStableCoin.transferFrom(msg.sender, address(this), _tokenamount);
            _resolvePayment(fees);
            _fowardPayment(payment, _to,_PayStableCoin);
            Uvinterface.mint(msg.sender);
            emit Paid(msg.sender, _to, _tokenamount);
            return true;
       }


   }

   function withdrawProfit (address _to, uint256 _amount) external payable returns(bool) {
       require(checkIsVendor(_to), "not a vendor");
      require(address(msg.sender) == address(universeToken), "you are not allowed to call this function");
        StableCoinInterface.approve(address(universeToken),_amount );
       rewardsPoolBalance -= _amount;
       StableCoinInterface.transfer(_to,_amount );
     StableCoinInterface.approve(address(universeToken),0 );
       return true;
   }

   function contractProfit() public payable onlyOwner returns(bool){ // works well
       uint256 _balance = StableCoinInterface.balanceOf(address(this));
       uint256 contractProfitBalance = _balance-rewardsPoolBalance;
       StableCoinInterface.transfer(msg.sender,contractProfitBalance );
       return true;
   }
    function fillQuote(
        // The `sellTokenAddress` field from the API response.
        IERC20 sellToken,
        // The `buyTokenAddress` field from the API response.
        IERC20 buyToken,
        // The `allowanceTarget` field from the API response.
        address spender,
        // The `to` field from the API response.
        address payable swapTarget,
        // The `data` field from the API response.
        bytes calldata swapCallData,
            // amount of tokens that needs to be sold
        uint256 _tokenamount,
        // amount to be actually paid
        uint256 _sendAmount,
        // // account to be paid
        address _toAddress
    )
        external
        // onlyOwner
        payable // Must attach ETH equal to the `value` field from the API response.
    {
        sellToken.transferFrom(msg.sender, address(this), _tokenamount);
        // allowance to 0 before being able to update it.
        require(sellToken.approve(spender, _tokenamount));
        // Call the encoded swap function call on the contract at `swapTarget`,
        // passing along any ETH attached to this function call to cover protocol fees.
        (bool success,) = swapTarget.call{value: msg.value}(swapCallData);
        // (bool success,) = swapTarget.call(swapCallData);
        require(success, 'SWAP_CALL_FAILED!');
       buyToken.transfer(_toAddress , _sendAmount);


/////// DONT FORGET TO REFUND BALANCE!!!
        // Refund any unspent protocol fees to the sender.
        // msg.sender.transfer(address(this).balance);
        // emit FilledSwapOrder(sellToken, buyToken, _tokenamount);
            emit Paid(msg.sender, _toAddress, _sendAmount);


    }
receive() external payable {}

}