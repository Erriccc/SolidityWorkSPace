# MAP3 PAY SPACE

#### Last update 8/9/2022

 contracts associated with Map3

 # SetUp

 MAp3 pay requires two addresses on deployment.

 ## 

 fee collector address and Weth(Wrapped native token) address for different networks

 ## 

 Vendor profiles requires the map3pay address on deployment

## 8/9/22 update..

Restructured contracts into account manager and payment processor. ie  (VendorAccountsManagerContract and Map3P2PContract).

### reasons?

we can now deploy multiple instances of the payment processors to take care of specific payment solutions.

ability to fix any bugs found in the payment system without disrupting account owners data.

limit vulnarability to just the payment contract, while mmaintaining intergrity of the vendors profile.

intention of restructuring account profiles into individual nfts will be more possible with one account manager.



## new contracts deployment details.

VendorAccountsManagerContract requires a fee colector address to be deployed.


Map3P2PContract requires VendorAccountsManagerContract address and Weth(wrapped contract for native tokens of any chain deployed on ie Wrapped matic for polygon ) address