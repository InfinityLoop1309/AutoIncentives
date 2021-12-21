from vyper.interfaces import ERC20

interface GaugeController:
    def last_user_vote(user_address: address, gauge_address: address)->int128: view    

token: public(address)
gauge: public(address)
incentive_amount: public(uint256)
claimed_list: HashMap[address, HashMap[address, HashMap[int128, bool]]]
balance: public(uint256)

CURVE_FI_CONTROLL_ADDR: address

@external
def __init__(_token: address, _incentive_amount: uint256, _gauge: address):
    self.token = _token
    self.incentive_amount = _incentive_amount
    self.gauge = _gauge
    self.balance = 0
    # the controller contract address
    self.CURVE_FI_CONTROLL_ADDR = 0x2F50D538606Fa9EDD2B11E2446BEb18C9D5846bB 

@external
def add_amount(_amount: uint256):
    _return_back: uint256 = _amount % self.incentive_amount 
    # if the bribe can not divided by the fix amount, the left should be returned back
    assert ERC20(self.token).transferFrom(msg.sender, self, _amount - _return_back)
    self.balance += _amount - _return_back

@external
def claim_reward(_voter_address:address):
    _time: int128 = GaugeController(self.CURVE_FI_CONTROLL_ADDR).last_user_vote(_voter_address, self.gauge)
    assert _time > 0 
    assert self.claimed_list[self.gauge][_voter_address][_time] == False
    # make sure the user has voted and hasn't claimed yet
    assert self.balance >= self.incentive_amount 
    # make sure there are enough rewards to send
    assert ERC20(self.token).transfer(_voter_address, self.incentive_amount)
    self.claimed_list[self.gauge][_voter_address][_time] = True
    self.balance -= self.incentive_amount
