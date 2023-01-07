// SPDX-License-Identifier: UNLICENSED

/*
- User is able to:
     deposit a token, 
     withdraw a token, 
     emergency withdraw all tokens, 
     show list of his tokens with their balances
- Be able to 
    transfer his deposited tokens for another user on the portifolio smart contract
- Bonus: add support for EIP-2612 compliant tokens for single transaction deposits

*/
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

interface ITask {
    function balances(address, address) external view returns (uint256);

    function deposit(address, uint256) external;

    function withdraw(address, uint256) external;

    function withdrawAll(address, uint256) external;
}

error UnrecognizedTokenAddress();
error FailedTransaction();

contract Task is Ownable {
    // address private _owner;

    mapping(address => mapping(address => uint256)) private _balances;
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private _set;

    event Deposit(
        address indexed tokenContractAdress,
        address indexed depositAddress,
        uint256 _amount
    );

    event Withdraw(address indexed tokenContractAdress, uint256 _amount);
    event WithdrawAll(address[] indexed tokenContractAdress, uint256[] _amount);

    function add(address _address) private returns (bool) {
        return _set.add(_address);
    }

    function remove(address _address) private returns (bool) {
        return _set.remove(_address);
    }

    function getAll() public view returns (bytes32[] memory) {
        // not used for removed
        return _set._inner._values;
    }

    function contains(address _address) public view returns (bool) {
        return _set.contains(_address);
    }

    function length() public view returns (uint256) {
        return _set.length();
    }

    /**
     * - index is to a way to find the token address in a set
     *
     */
    function balanceAt(uint256 index) public view returns (uint256) {
        return _balances[_set.at(index)][owner()];
    }

    /**
     * - _address is the token address
     *
     */
    function balanceAt(address _address) public view returns (uint256) {
        return _balances[_address][owner()];
    }

    /*
      retrun the address of an index 
    */
    function at(uint256 index) public view returns (address) {
        return _set.at(index);
    }

    /*
    return two lists one tokens address and
    sencond of their balances
    */
    function balanceOf()
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        address _owner = owner();
        address[] memory res = new address[](_set.length());
        uint256[] memory bal = new uint256[](_set.length());

        for (uint256 i = 0; i < _set.length(); i++) {
            // address _add = at(i);
            res[i] = at(i);
            bal[i] = _balances[res[i]][_owner];
        }
        return (res, bal);
    }

    function balanceOf2()
        public
        view
        returns (address[] memory, uint256[] memory)
    {
        address _owner = owner();
        address[] memory res = new address[](_set.length());
        uint256[] memory bal = new uint256[](_set.length());

        for (uint256 i = 0; i < _set.length(); ++i) {
            // address _add = at(i);
            res[i] = at(i);
            bal[i] = _balances[res[i]][_owner];
        }
        return (res, bal);
    }

    function deposit(
        address _tokenAdress,
        address depositAddress,
        uint256 _amount
    ) external returns (bool) {
        address _owner = owner();
        require(_amount > 0, "amount needs to be greater than 0");
        bool isAdded = add(_tokenAdress);

        if (!isAdded) {
            // _balances[_tokenAdress][_owner] = _amount;
            _balances[_tokenAdress][_owner] += _amount;
        } else {
            _balances[_tokenAdress][_owner] = _amount;
        }

        bool res = IERC20(_tokenAdress).transferFrom(
            depositAddress,
            address(this),
            _amount
        );
        if (!res) FailedTransaction;
        emit Deposit(_tokenAdress, depositAddress, _amount);
        return res;
    }

    function withdraw(address _tokenAdress) external onlyOwner returns (bool) {
        bool isContains = contains(_tokenAdress);
        if (!isContains) revert UnrecognizedTokenAddress();
        uint256 _amount = _balances[_tokenAdress][msg.sender];
        require(_amount > 0, "NO Balance"); // second layer check
        _balances[_tokenAdress][msg.sender] -= _amount;
        remove(_tokenAdress);
        bool res = IERC20(_tokenAdress).transfer(msg.sender, _amount);
        if (!res) FailedTransaction;
        emit Withdraw(_tokenAdress, _amount);
        return res;
    }

    function _withdraw(address _tokenAdress, uint256 _amount)
        external
        onlyOwner
    {
        bool isContains = contains(_tokenAdress);
        if (!isContains) revert UnrecognizedTokenAddress();
        _balances[_tokenAdress][msg.sender] -= _amount;

        IERC20(_tokenAdress).transfer(msg.sender, _amount);
    }

    function withdrawAll() external onlyOwner returns (bool res) {
        address _owner = owner();
        address[] memory _tokenAddress = new address[](_set.length());
        uint256[] memory _amount = new uint256[](_set.length());
        uint256 len = length();
        uint256 i;
        if (len <= 0) {
            return false;
        }
        for (i = 0; i < len; ++i) {
            // address _add = at(i);
            _tokenAddress[i] = at(i);
            _amount[i] = _balances[_tokenAddress[i]][_owner];
            // require(_amount[i] > 0, "No Balance");

            _balances[_tokenAddress[i]][_owner] -= _amount[i];
            res = IERC20(_tokenAddress[i]).transfer(_owner, _amount[i]);
            if (!res) FailedTransaction;
        }
        for (i = 0; i < len; ++i) {
            remove(_tokenAddress[i]);
        }
    }

    function deposits(
        address _tokenAdress,
        // address _owner,
        // address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool) {
        address owner = owner();
        require(value > 0, "amount needs to be greater than 0");
        IERC20Permit(_tokenAdress).permit(
            owner,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        bool isAdded = add(_tokenAdress);
        if (!isAdded) {
            // _balances[_tokenAdress][_owner] = _amount;
            _balances[_tokenAdress][owner] += value;
        } else {
            _balances[_tokenAdress][owner] = value;
        }
        bool res = IERC20(_tokenAdress).transferFrom(
            owner,
            address(this),
            value
        );

        if (!res) FailedTransaction;
        emit Deposit(_tokenAdress, owner, value);
        return res;
    }

    // function withdrawAll2() external onlyOwner returns (bool res) {
    //     address _owner = owner();
    //     address[] memory _tokenAddress = new address[](_set.length());
    //     uint256[] memory _amount = new uint256[](_set.length());
    //     uint256 len = length();
    //     uint256 i;
    //     for (i = 0; i <= len; ++i) {
    //         // address _add = at(i);
    //         _tokenAddress[i] = at(i);
    //         _amount[i] = _balances[_tokenAddress[i]][_owner];
    //         // require(_amount[i] > 0, "No Balance");

    //         _balances[_tokenAddress[i]][_owner] -= _amount[i];
    //         res = IERC20(_tokenAddress[i]).transfer(_owner, _amount[i]);
    //         // remove(_tokenAddress[i]);
    //         if (!res) FailedTransaction;
    //     }
    // }
}
