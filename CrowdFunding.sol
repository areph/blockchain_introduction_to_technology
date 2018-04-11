pragma solidity ^0.4.19;
contract CrowdFunding {
  // 投資家
  struct Investor {
    address addr;
    uint amount;
  }

  address public owner;
  uint public numInvestors;
  uint public deadline;
  string public status;
  bool public ended;
  uint public goalAmount;
  uint public totalAmount;
  mapping (uint => Investor) public investors;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function CrowdFunding(uint _duration, uint _goalAmount) public {
    owner = msg.sender;

    deadline = now + _duration;

    goalAmount = _goalAmount;
    status = "Funding";
    ended = false;

    numInvestors = 0;
    totalAmount = 0;
  }

  function fund() public payable {
    require(!ended);

    Investor storage inv = investors[numInvestors++];
    inv.addr = msg.sender;
    inv.amount = msg.value;
    totalAmount += inv.amount;
  }

  function checkGoalReached() public onlyOwner {
    require(!ended);
    require(now >= deadline);

    if (totalAmount >= goalAmount) {
      status = "Campaign Succeeded";
      ended = true;
      assert(owner.send(address(this).balance));
    } else {
      uint i = 0;
      status = "Campaign Failed";
      ended = true;

      // 投資家全て全てに返金する処理
      while (i <= numInvestors) {
        assert(investors[i].addr.send(investors[i].amount));
        i++;
      }
    }
  }

  function kill() public onlyOwner {
    selfdestruct(owner);
  }
}
